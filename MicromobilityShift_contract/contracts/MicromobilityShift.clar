
;; title: MicromobilityShift
;; version: 1.0.0
;; summary: Synthetic assets smart contract for tracking e-scooters, bike-sharing, and urban mobility trends
;; description: This contract manages synthetic assets representing different types of micromobility vehicles
;;              and tracks their performance metrics across urban environments

;; traits
;;

;; token definitions
;; Define SIP-010 compliant token for synthetic mobility assets
(define-fungible-token mobility-token)

;; constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-asset (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-asset-not-found (err u103))
(define-constant err-invalid-price (err u104))
(define-constant err-unauthorized (err u105))

;; Asset types
(define-constant ESCOOTER u1)
(define-constant BIKE-SHARE u2)
(define-constant ELECTRIC-BIKE u3)
(define-constant CARGO-BIKE u4)

;; data vars
(define-data-var total-assets uint u0)
(define-data-var contract-paused bool false)

;; data maps
;; Track synthetic assets with their metadata
(define-map assets
    { asset-id: uint }
    {
        asset-type: uint,
        name: (string-ascii 50),
        price: uint,
        total-supply: uint,
        circulating-supply: uint,
        last-updated: uint,
        performance-score: uint
    }
)

;; Track user balances for each asset
(define-map user-balances
    { user: principal, asset-id: uint }
    { balance: uint }
)

;; Track mobility metrics for each asset type
(define-map mobility-metrics
    { asset-type: uint, location: (string-ascii 30) }
    {
        usage-count: uint,
        average-trip-duration: uint,
        total-distance: uint,
        carbon-offset: uint,
        last-updated: uint
    }
)

;; Track authorized operators who can update metrics
(define-map authorized-operators
    { operator: principal }
    { authorized: bool }
)

;; public functions

;; Create a new synthetic asset
(define-public (create-asset (asset-type uint) (name (string-ascii 50)) (initial-price uint) (total-supply uint))
    (let (
        (new-asset-id (+ (var-get total-assets) u1))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (asserts! (or (is-eq asset-type ESCOOTER)
                     (is-eq asset-type BIKE-SHARE)
                     (is-eq asset-type ELECTRIC-BIKE)
                     (is-eq asset-type CARGO-BIKE)) err-invalid-asset)
        (asserts! (> initial-price u0) err-invalid-price)

        (map-set assets
            { asset-id: new-asset-id }
            {
                asset-type: asset-type,
                name: name,
                price: initial-price,
                total-supply: total-supply,
                circulating-supply: u0,
                last-updated: block-height,
                performance-score: u50
            }
        )

        (var-set total-assets new-asset-id)
        (ok new-asset-id)
    )
)

;; Mint synthetic assets to a user
(define-public (mint-asset (asset-id uint) (recipient principal) (amount uint))
    (let (
        (asset-data (unwrap! (map-get? assets { asset-id: asset-id }) err-asset-not-found))
        (current-balance (default-to u0 (get balance (map-get? user-balances { user: recipient, asset-id: asset-id }))))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (asserts! (<= (+ (get circulating-supply asset-data) amount) (get total-supply asset-data)) err-insufficient-balance)

        ;; Update user balance
        (map-set user-balances
            { user: recipient, asset-id: asset-id }
            { balance: (+ current-balance amount) }
        )

        ;; Update circulating supply
        (map-set assets
            { asset-id: asset-id }
            (merge asset-data { circulating-supply: (+ (get circulating-supply asset-data) amount) })
        )

        ;; Mint tokens
        (try! (ft-mint? mobility-token amount recipient))
        (ok true)
    )
)

;; Update asset price based on market conditions
(define-public (update-asset-price (asset-id uint) (new-price uint))
    (let (
        (asset-data (unwrap! (map-get? assets { asset-id: asset-id }) err-asset-not-found))
    )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (asserts! (> new-price u0) err-invalid-price)

        (map-set assets
            { asset-id: asset-id }
            (merge asset-data {
                price: new-price,
                last-updated: block-height
            })
        )
        (ok true)
    )
)

;; Update mobility metrics (only authorized operators)
(define-public (update-mobility-metrics
    (asset-type uint)
    (location (string-ascii 30))
    (usage-count uint)
    (avg-trip-duration uint)
    (total-distance uint)
    (carbon-offset uint))
    (begin
        (asserts! (default-to false (get authorized (map-get? authorized-operators { operator: tx-sender }))) err-unauthorized)
        (asserts! (not (var-get contract-paused)) err-unauthorized)

        (map-set mobility-metrics
            { asset-type: asset-type, location: location }
            {
                usage-count: usage-count,
                average-trip-duration: avg-trip-duration,
                total-distance: total-distance,
                carbon-offset: carbon-offset,
                last-updated: block-height
            }
        )
        (ok true)
    )
)

;; Add authorized operator
(define-public (add-authorized-operator (operator principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-operators
            { operator: operator }
            { authorized: true }
        )
        (ok true)
    )
)

;; Transfer synthetic assets between users
(define-public (transfer-asset (asset-id uint) (sender principal) (recipient principal) (amount uint))
    (let (
        (sender-balance (default-to u0 (get balance (map-get? user-balances { user: sender, asset-id: asset-id }))))
        (recipient-balance (default-to u0 (get balance (map-get? user-balances { user: recipient, asset-id: asset-id }))))
    )
        (asserts! (is-eq tx-sender sender) err-unauthorized)
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (asserts! (>= sender-balance amount) err-insufficient-balance)

        ;; Update sender balance
        (map-set user-balances
            { user: sender, asset-id: asset-id }
            { balance: (- sender-balance amount) }
        )

        ;; Update recipient balance
        (map-set user-balances
            { user: recipient, asset-id: asset-id }
            { balance: (+ recipient-balance amount) }
        )

        (ok true)
    )
)

;; Emergency pause function
(define-public (toggle-contract-pause)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set contract-paused (not (var-get contract-paused)))
        (ok (var-get contract-paused))
    )
)

;; read only functions

;; Get asset information
(define-read-only (get-asset-info (asset-id uint))
    (map-get? assets { asset-id: asset-id })
)

;; Get user balance for specific asset
(define-read-only (get-user-balance (user principal) (asset-id uint))
    (default-to u0 (get balance (map-get? user-balances { user: user, asset-id: asset-id })))
)

;; Get mobility metrics for asset type and location
(define-read-only (get-mobility-metrics (asset-type uint) (location (string-ascii 30)))
    (map-get? mobility-metrics { asset-type: asset-type, location: location })
)

;; Get total number of assets
(define-read-only (get-total-assets)
    (var-get total-assets)
)

;; Check if contract is paused
(define-read-only (is-contract-paused)
    (var-get contract-paused)
)

;; Check if operator is authorized
(define-read-only (is-authorized-operator (operator principal))
    (default-to false (get authorized (map-get? authorized-operators { operator: operator })))
)

;; Get contract owner
(define-read-only (get-contract-owner)
    contract-owner
)

;; Calculate performance score based on metrics
(define-read-only (calculate-performance-score (asset-type uint) (location (string-ascii 30)))
    (match (map-get? mobility-metrics { asset-type: asset-type, location: location })
        metrics
        (let (
            (usage-score (get-min u40 (/ (get usage-count metrics) u10)))
            (efficiency-score (get-min u30 (/ (get total-distance metrics) u100)))
            (environmental-score (get-min u30 (/ (get carbon-offset metrics) u50)))
        )
            (+ usage-score efficiency-score environmental-score)
        )
        u0
    )
)

;; private functions

;; Helper function to get minimum of two values
(define-private (get-min (a uint) (b uint))
    (if (<= a b) a b)
)

;; Helper function to validate asset type
(define-private (is-valid-asset-type (asset-type uint))
    (or (is-eq asset-type ESCOOTER)
        (is-eq asset-type BIKE-SHARE)
        (is-eq asset-type ELECTRIC-BIKE)
        (is-eq asset-type CARGO-BIKE))
)

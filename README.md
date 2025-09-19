# MicromobilityShift

**A Synthetic Assets Smart Contract for Urban Mobility Tracking**

MicromobilityShift is a Clarity smart contract that creates and manages synthetic assets representing different types of micromobility vehicles (e-scooters, bike-sharing, electric bikes, and cargo bikes) while tracking their performance metrics across urban environments.

## 🚀 Features

- **Synthetic Asset Creation**: Create tokenized representations of micromobility vehicles
- **Multi-Asset Support**: Support for 4 vehicle types (e-scooters, bike-share, electric bikes, cargo bikes)
- **Performance Tracking**: Real-time monitoring of usage metrics, trip data, and environmental impact
- **SIP-010 Compliance**: Fungible token standard implementation for asset trading
- **Location-Based Analytics**: Track metrics by geographic location
- **Carbon Offset Tracking**: Monitor environmental benefits of micromobility usage
- **Access Control**: Role-based permissions for operators and contract management
- **Emergency Controls**: Pausable contract functionality for security

## 🏗️ Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity 2.0
- **Epoch**: 2.5
- **Token Standard**: SIP-010 Fungible Token
- **Contract Version**: 1.0.0

### Supported Asset Types

| Asset Type | ID | Description |
|------------|----| ------------|
| E-Scooter | 1 | Electric scooters for short-distance travel |
| Bike-Share | 2 | Traditional bike-sharing systems |
| Electric Bike | 3 | E-bikes with electric assistance |
| Cargo Bike | 4 | Bikes designed for carrying goods |

## 📦 Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Node.js 16+ for testing
- Git

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd MicromobilityShift
```

2. Navigate to the contract directory:
```bash
cd MicromobilityShift_contract
```

3. Install dependencies:
```bash
npm install
```

4. Run tests:
```bash
npm test
```

## 🔧 Usage Examples

### Creating a New Asset

```clarity
;; Create an e-scooter asset with initial price of 1000 and total supply of 10000
(contract-call? .MicromobilityShift create-asset u1 "Urban E-Scooter" u1000 u10000)
```

### Minting Assets to Users

```clarity
;; Mint 100 units of asset ID 1 to a user
(contract-call? .MicromobilityShift mint-asset u1 'SP1ABC...XYZ u100)
```

### Updating Mobility Metrics

```clarity
;; Update metrics for e-scooters in downtown area
(contract-call? .MicromobilityShift update-mobility-metrics
    u1
    "downtown"
    u500    ;; usage count
    u15     ;; average trip duration (minutes)
    u7500   ;; total distance (meters)
    u250    ;; carbon offset (grams CO2)
)
```

### Transferring Assets

```clarity
;; Transfer 50 units of asset ID 1 from sender to recipient
(contract-call? .MicromobilityShift transfer-asset u1 tx-sender 'SP1DEF...ABC u50)
```

## 📋 Contract Functions

### Public Functions

#### Asset Management
- `create-asset(asset-type, name, initial-price, total-supply)` - Create new synthetic asset
- `mint-asset(asset-id, recipient, amount)` - Mint tokens to user
- `update-asset-price(asset-id, new-price)` - Update asset pricing
- `transfer-asset(asset-id, sender, recipient, amount)` - Transfer assets between users

#### Metrics & Operations
- `update-mobility-metrics(asset-type, location, usage-count, avg-trip-duration, total-distance, carbon-offset)` - Update performance data
- `add-authorized-operator(operator)` - Grant operator permissions
- `toggle-contract-pause()` - Emergency pause/unpause

### Read-Only Functions

#### Asset Information
- `get-asset-info(asset-id)` - Retrieve asset details
- `get-user-balance(user, asset-id)` - Check user's asset balance
- `get-total-assets()` - Get total number of assets created

#### Metrics & Status
- `get-mobility-metrics(asset-type, location)` - Retrieve location-specific metrics
- `calculate-performance-score(asset-type, location)` - Calculate performance score (0-100)
- `is-contract-paused()` - Check if contract is paused
- `is-authorized-operator(operator)` - Check operator authorization
- `get-contract-owner()` - Get contract owner address

## 🚀 Deployment Guide

### Local Development (Devnet)

1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy the contract:
```clarity
::deploy_contracts
```

3. Test contract functions in the console.

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`

2. Deploy using Clarinet:
```bash
clarinet deployments deploy --network testnet
```

### Mainnet Deployment

1. Update `settings/Mainnet.toml` with production parameters

2. Deploy to mainnet:
```bash
clarinet deployments deploy --network mainnet
```

## 🔒 Security Notes

### Access Control
- **Contract Owner**: Can create assets, mint tokens, update prices, and manage operators
- **Authorized Operators**: Can update mobility metrics only
- **Emergency Controls**: Contract can be paused to halt all operations

### Security Features
- Input validation for all parameters
- Balance checks before transfers
- Supply cap enforcement
- Role-based access control
- Emergency pause functionality

### Best Practices
- Regularly audit authorized operators
- Monitor asset price updates for anomalies
- Validate mobility metrics before updating
- Use emergency pause during suspected attacks
- Keep private keys secure for owner functions

### Error Codes
- `u100`: Owner-only function called by non-owner
- `u101`: Invalid asset type specified
- `u102`: Insufficient balance for operation
- `u103`: Asset not found
- `u104`: Invalid price (must be > 0)
- `u105`: Unauthorized access or contract paused

## 🧪 Testing

Run the test suite:
```bash
npm test
```

Run tests with coverage:
```bash
npm run test:report
```

Watch mode for development:
```bash
npm run test:watch
```

## 📊 Performance Scoring

The contract calculates performance scores (0-100) based on three factors:

- **Usage Score** (40% max): Based on usage frequency
- **Efficiency Score** (30% max): Based on total distance covered
- **Environmental Score** (30% max): Based on carbon offset achieved

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the ISC License.

## 🔗 Links

- [Stacks Documentation](https://docs.stacks.co/)
- [Clarity Language Reference](https://docs.stacks.co/clarity/)
- [SIP-010 Token Standard](https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md)
- [Clarinet Documentation](https://github.com/hirosystems/clarinet)

---

**Built with ❤️ for sustainable urban mobility**
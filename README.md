# ClearTitle

A blockchain-powered real estate platform for tracking property titles, construction materials, and asset provenance to prevent title fraud, ensure sustainable building practices, and streamline commercial real estate transactions.

---

## Overview

ClearTitle leverages blockchain technology to provide a transparent, secure, and efficient system for managing real estate assets. It consists of five main smart contracts built with Clarity to address key challenges in commercial real estate, such as title fraud, lack of transparency in construction materials, and disputes over property histories.

1. **Title Registry Contract** – Manages property title ownership and transfer history.
2. **Material Provenance Contract** – Tracks construction materials for sustainability and compliance.
3. **Green Certification Contract** – Verifies and records green building certifications (e.g., LEED).
4. **IoT Sensor Data Contract** – Integrates IoT sensor data for real-time construction monitoring.
5. **Transaction Escrow Contract** – Facilitates secure and transparent property transactions.

---

## Features

- **Secure title tracking** with tokenized title deeds and status codes (e.g., "title-transferred," "inspected")  
- **Material provenance** for transparency in sustainable sourcing  
- **Green certification verification** for compliance with standards like LEED  
- **IoT integration** for real-time monitoring of construction processes  
- **Escrow-based transactions** to reduce disputes and ensure trust  
- **Immutable audit trail** for property and asset history  
- **Tokenized title deeds** for fractional ownership and liquidity  
- **Real-time data updates** via IoT and oracle integration  

---

## Smart Contracts

### Title Registry Contract
- Registers property titles as tokenized assets
- Tracks ownership changes with status codes (e.g., "title-transferred," "inspected")
- Stores immutable history of title transfers

### Material Provenance Contract
- Logs sourcing and usage of construction materials
- Verifies sustainability credentials via oracle integration
- Tracks batch IDs and supplier details

### Green Certification Contract
- Records and verifies green certifications (e.g., LEED, BREEAM)
- Updates certification status with expiration checks
- Provides public access to certification details

### IoT Sensor Data Contract
- Integrates IoT sensor data for construction monitoring (e.g., material usage, structural integrity)
- Stores sensor logs on-chain for transparency
- Validates data integrity via oracle feeds

### Transaction Escrow Contract
- Manages escrow for property transactions
- Releases funds upon title transfer and inspection confirmation
- Automates dispute resolution with predefined conditions

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/cleartitle.git
   ```
3. Run tests:
    ```bash
    npm test
    ```
4. Deploy contracts:
    ```bash
    clarinet deploy
    ```

## Usage

Each smart contract is designed to operate independently but integrates seamlessly with others to form a comprehensive real estate management system. Refer to individual contract documentation for function calls, parameters, and usage examples.

## License

MIT License


# frozen_string_literal: true

module Viem
  module Chains
    MAINNET = Chain.new(
      id: 1,
      name: "Ethereum",
      network: "homestead",
      native_currency: NativeCurrency.new(name: "Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://cloudflare-eth.com"] } },
      block_explorers: { default: { name: "Etherscan", url: "https://etherscan.io" } },
      testnet: false,
    )

    SEPOLIA = Chain.new(
      id: 11_155_111,
      name: "Sepolia",
      network: "sepolia",
      native_currency: NativeCurrency.new(name: "Sepolia Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://rpc.sepolia.org"] } },
      block_explorers: { default: { name: "Etherscan", url: "https://sepolia.etherscan.io" } },
      testnet: true,
    )

    GOERLI = Chain.new(
      id: 5,
      name: "Goerli",
      network: "goerli",
      native_currency: NativeCurrency.new(name: "Goerli Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://rpc.ankr.com/eth_goerli"] } },
      block_explorers: { default: { name: "Etherscan", url: "https://goerli.etherscan.io" } },
      testnet: true,
    )

    POLYGON = Chain.new(
      id: 137,
      name: "Polygon",
      network: "matic",
      native_currency: NativeCurrency.new(name: "MATIC", symbol: "MATIC", decimals: 18),
      rpc_urls: { default: { http: ["https://polygon-rpc.com"] } },
      block_explorers: { default: { name: "PolygonScan", url: "https://polygonscan.com" } },
      testnet: false,
    )

    POLYGON_MUMBAI = Chain.new(
      id: 80_001,
      name: "Polygon Mumbai",
      network: "maticmum",
      native_currency: NativeCurrency.new(name: "MATIC", symbol: "MATIC", decimals: 18),
      rpc_urls: { default: { http: ["https://rpc-mumbai.maticvigil.com"] } },
      block_explorers: { default: { name: "PolygonScan", url: "https://mumbai.polygonscan.com" } },
      testnet: true,
    )

    OPTIMISM = Chain.new(
      id: 10,
      name: "Optimism",
      network: "optimism",
      native_currency: NativeCurrency.new(name: "Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://mainnet.optimism.io"] } },
      block_explorers: { default: { name: "Optimism Explorer", url: "https://optimistic.etherscan.io" } },
      testnet: false,
    )

    OPTIMISM_GOERLI = Chain.new(
      id: 420,
      name: "Optimism Goerli",
      network: "optimism-goerli",
      native_currency: NativeCurrency.new(name: "Goerli Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://goerli.optimism.io"] } },
      block_explorers: { default: { name: "Optimism Explorer", url: "https://goerli-optimism.etherscan.io" } },
      testnet: true,
    )

    ARBITRUM = Chain.new(
      id: 42_161,
      name: "Arbitrum One",
      network: "arbitrum",
      native_currency: NativeCurrency.new(name: "Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://arb1.arbitrum.io/rpc"] } },
      block_explorers: { default: { name: "Arbiscan", url: "https://arbiscan.io" } },
      testnet: false,
    )

    ARBITRUM_GOERLI = Chain.new(
      id: 421_613,
      name: "Arbitrum Goerli",
      network: "arbitrum-goerli",
      native_currency: NativeCurrency.new(name: "Arbitrum Goerli Ether", symbol: "AGOR", decimals: 18),
      rpc_urls: { default: { http: ["https://goerli-rollup.arbitrum.io/rpc"] } },
      block_explorers: { default: { name: "Arbiscan", url: "https://goerli.arbiscan.io" } },
      testnet: true,
    )

    BASE = Chain.new(
      id: 8453,
      name: "Base",
      network: "base",
      native_currency: NativeCurrency.new(name: "Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://mainnet.base.org"] } },
      block_explorers: { default: { name: "Basescan", url: "https://basescan.org" } },
      testnet: false,
    )

    BASE_GOERLI = Chain.new(
      id: 84_531,
      name: "Base Goerli",
      network: "base-goerli",
      native_currency: NativeCurrency.new(name: "Goerli Ether", symbol: "ETH", decimals: 18),
      rpc_urls: { default: { http: ["https://goerli.base.org"] } },
      block_explorers: { default: { name: "Basescan", url: "https://goerli.basescan.org" } },
      testnet: true,
    )

    AVALANCHE = Chain.new(
      id: 43_114,
      name: "Avalanche",
      network: "avalanche",
      native_currency: NativeCurrency.new(name: "Avalanche", symbol: "AVAX", decimals: 18),
      rpc_urls: { default: { http: ["https://api.avax.network/ext/bc/C/rpc"] } },
      block_explorers: { default: { name: "SnowTrace", url: "https://snowtrace.io" } },
      testnet: false,
    )

    AVALANCHE_FUJI = Chain.new(
      id: 43_113,
      name: "Avalanche Fuji",
      network: "avalanche-fuji",
      native_currency: NativeCurrency.new(name: "Avalanche", symbol: "AVAX", decimals: 18),
      rpc_urls: { default: { http: ["https://api.avax-test.network/ext/bc/C/rpc"] } },
      block_explorers: { default: { name: "SnowTrace", url: "https://testnet.snowtrace.io" } },
      testnet: true,
    )

    BSC = Chain.new(
      id: 56,
      name: "BNB Smart Chain",
      network: "bsc",
      native_currency: NativeCurrency.new(name: "BNB", symbol: "BNB", decimals: 18),
      rpc_urls: { default: { http: ["https://bsc-dataseed.binance.org"] } },
      block_explorers: { default: { name: "BscScan", url: "https://bscscan.com" } },
      testnet: false,
    )

    BSC_TESTNET = Chain.new(
      id: 97,
      name: "BNB Smart Chain Testnet",
      network: "bsc-testnet",
      native_currency: NativeCurrency.new(name: "BNB", symbol: "tBNB", decimals: 18),
      rpc_urls: { default: { http: ["https://data-seed-prebsc-1-s1.binance.org:8545"] } },
      block_explorers: { default: { name: "BscScan", url: "https://testnet.bscscan.com" } },
      testnet: true,
    )

    GNOSIS = Chain.new(
      id: 100,
      name: "Gnosis",
      network: "gnosis",
      native_currency: NativeCurrency.new(name: "xDAI", symbol: "xDAI", decimals: 18),
      rpc_urls: { default: { http: ["https://rpc.gnosischain.com"] } },
      block_explorers: { default: { name: "Gnosis Scan", url: "https://gnosisscan.io" } },
      testnet: false,
    )

    FANTOM = Chain.new(
      id: 250,
      name: "Fantom",
      network: "fantom",
      native_currency: NativeCurrency.new(name: "Fantom", symbol: "FTM", decimals: 18),
      rpc_urls: { default: { http: ["https://rpc.ftm.tools"] } },
      block_explorers: { default: { name: "FtmScan", url: "https://ftmscan.com" } },
      testnet: false,
    )

    CELO = Chain.new(
      id: 42_220,
      name: "Celo",
      network: "celo",
      native_currency: NativeCurrency.new(name: "CELO", symbol: "CELO", decimals: 18),
      rpc_urls: { default: { http: ["https://forno.celo.org"] } },
      block_explorers: { default: { name: "Celo Explorer", url: "https://explorer.celo.org" } },
      testnet: false,
    )
  end
end

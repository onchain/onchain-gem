require 'onchain'
require 'webmock/rspec'
require 'vcr'    
require 'support/vcr_setup.rb'
WebMock.disable_net_connect!(allow: ['explorer.testnet.z.cash', 'explorer.z.cash', 'blockdozer.com', 
    'test-insight.bitpay.com', 'blockchain.info', 'tbtc.blockr.io', 'insight.bitpay.com', 
    'z.cash', 'bitstamp.net']) 

MPK = "xpub69n5sWwu7AAuyxEGp6MD5NeW58vBcUYoJB2CMFFsAjxJvpoJkQd78NSRVL3kzjd4rprvrLi2iKnm3QJCTfcTZSsfs5SnQgK7e2mu7EuUko9"

PAYMENT = [['1STRonGxnFTeJiA7pgyneKknR29AwBM77', 500], 
  ['1Nj3AsYfhHC4zVv1HHH4FzsYWeZSeVC8vj', 500]]
  
REDEMPTION_SCRIPT_WITH_BALANCE = "5121024f96aaf26b108553afbb6ca36bc9fa73ebcef919dc811296970e3b925394b32451ae"
REDEMPTION_SCRIPT_NO_BALANCE = "512103d2e757463f9a6a119d340640f0d7db2b07d34314716855151af16634c7af381851ae"

# Sweeper MPK's
MPK1 = "xpub661MyMwAqRbcErqsNepjao8S2u615n5jFTRfJQdMMahL6KJxyXVni3RtFyBrBobQteHWsMNApyJ4irFkPorinDpXQPysDxnipWhyBR7pMWw"
MPK2 = "xpub661MyMwAqRbcGnnsCzY5phYMGV6i2TFpg3xBR26Jm1N9roPd9yMNHqXr3M1juQUdLCgRf2DwtRSJUhpMH26Ji1TE9NaYDoVX92RngPdcjby"
MPK3 = "xpub661MyMwAqRbcFQQrJC1ZavniEzL43iFWsQMx16oqxzufmvrtktqccHr1LV4WGwHe2bimoHyF9rsWKX7PUZ9nTgA8FGn8d43gngMMmbKgqG2"

# Associate private keys
MPKP1 = "xprv9s21ZrQH143K2NmQGdHjDfBhUsFWgKMstEW4W2DjoFAMDWypRzBYAF7QQiNjHwxH1XQEnbMvcDiixoHHob6jB7xvw74ji35zNiFiqXNLTCb"
MPKP2 = "xprv9s21ZrQH143K4JiQ6y15TZbciTGDczXyJq2acdghCfqAz14UcS37k3DNC5JXuDqi7KcWPXdr1r3xDfE3dsygHLZGGgrRvNaREnsUpEivqYd"
MPKP3 = "xprv9s21ZrQH143K2vLPCAUZDnqygxVZeFXfWBSMCiQEQfNgu8XkDMXN4VXXVDE5cFtb7FHxiaKjo6eWJ8wL3KEK4VGCZLRtYVnKtUBz9oP7Th9"

# BitDice MPK
BITMPKP = "xpub69GZWTQPtwQRriHyYuYJpDgAUrHHRD8ksBbQ61QpY1CbSUrcW7udYcZ1YLuLVtSQx9xW5QApiGidDfmFVLEz4Lep3AoCGD2HQmfvXwH1GMt"
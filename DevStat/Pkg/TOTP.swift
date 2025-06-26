import CryptoKit
import Foundation
import SwiftUI

func genTOTP(_ secret: String) -> String {
  // Remove spaces and convert to uppercase
  let cleanSecret = secret.replacingOccurrences(of: " ", with: "").uppercased()

  // Base32 decode the secret
  guard let secretData = base32Decode(cleanSecret) else {
    return "000000"
  }

  // Get current Unix time and divide by 30 (time step)
  let currentTime = UInt64(Date().timeIntervalSince1970)
  let timeCounter = currentTime / 30

  // Convert counter to 8-byte big-endian data
  var counter = timeCounter.bigEndian
  let counterData = Data(bytes: &counter, count: 8)

  // Compute HMAC-SHA1
  let key = SymmetricKey(data: secretData)
  let hmac = HMAC<Insecure.SHA1>.authenticationCode(for: counterData, using: key)
  let hmacBytes = Array(hmac)

  // Dynamic truncation
  let offset = Int(hmacBytes[19] & 0x0f)
  let fourBytes = Array(hmacBytes[offset..<offset + 4])

  // Convert to integer and mask the most significant bit
  let binaryCode =
    (UInt32(fourBytes[0]) << 24) | (UInt32(fourBytes[1]) << 16) | (UInt32(fourBytes[2]) << 8)
    | UInt32(fourBytes[3])

  let maskedCode = binaryCode & 0x7fff_ffff
  let otp = maskedCode % 1_000_000

  // Return as 6-digit string with leading zeros
  return String(format: "%06d", otp)
}

// Base32 decoding function
private func base32Decode(_ input: String) -> Data? {
  let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
  let base32Map = Dictionary(uniqueKeysWithValues: zip(base32Alphabet, 0..<32))

  let cleanInput = input.replacingOccurrences(of: "=", with: "")
  var result = Data()
  var buffer: UInt64 = 0
  var bitsLeft = 0

  for char in cleanInput {
    guard let value = base32Map[char] else {
      return nil
    }

    buffer = (buffer << 5) | UInt64(value)
    bitsLeft += 5

    if bitsLeft >= 8 {
      result.append(UInt8((buffer >> (bitsLeft - 8)) & 0xff))
      bitsLeft -= 8
    }
  }

  return result
}

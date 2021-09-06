//
//  Extensions.swift
//  Manager
//
//  Created by Sakshi patil on 01/09/2021.
//

import Foundation

import SwiftUI
import CommonCrypto

struct AES {

    // MARK: - Value
    // MARK: Private
    private let key: Data
    private let iv: Data


    // MARK: - Initialzier
    init?(key: String, iv: String) {
        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
            debugPrint("Error: Failed to set a key.")
            return nil
        }

        guard iv.count == kCCBlockSizeAES128, let ivData = iv.data(using: .utf8) else {
            debugPrint("Error: Failed to set an initial vector.")
            return nil
        }


        self.key = keyData
        self.iv  = ivData
    }


    // MARK: - Function
    // MARK: Public
    func encrypt(string: String) -> Data? {
        return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
    }

    func decrypt(data: Data?) -> String? {
        guard let decryptedData = crypt(data: data, option: CCOperation(kCCDecrypt)) else { return nil }
        return String(bytes: decryptedData, encoding: .utf8)
    }

    func crypt(data: Data?, option: CCOperation) -> Data? {
        guard let data = data else { return nil }

        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData   = Data(count: cryptLength)

        let keyLength = key.count
        let options   = CCOptions(kCCOptionPKCS7Padding)

        var bytesLength = Int(0)

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }

        guard UInt32(status) == UInt32(kCCSuccess) else {
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }

        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}


extension String {
    

        func hexToString()->String{
            
            var finalString = ""
            let chars = Array(self)
            
            for count in stride(from: 0, to: chars.count - 1, by: 2){
                let firstDigit =  Int.init("\(chars[count])", radix: 16) ?? 0
                let lastDigit = Int.init("\(chars[count + 1])", radix: 16) ?? 0
                let decimal = firstDigit * 16 + lastDigit
                let decimalString = String(format: "%c", decimal) as String
                finalString.append(Character.init(decimalString))
            }
            return finalString
            
        }
        
        func base64Decoded() -> String? {
            guard let data = Data(base64Encoded: self) else { return nil }
            return String(data: data, encoding: .init(rawValue: 0))
        }
    
    
    
    func md5Hash (str: String) -> String {
        if let strData = str.data(using: String.Encoding.utf8) {
            /// #define CC_MD5_DIGEST_LENGTH    16          /* digest length in bytes */
            /// Creates an array of unsigned 8 bit integers that contains 16 zeros
            var digest = [UInt8](repeating: 0, count:Int(CC_MD5_DIGEST_LENGTH))
     
            /// CC_MD5 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
            /// Calls the given closure with a pointer to the underlying unsafe bytes of the strData’s contiguous storage.
            strData.withUnsafeBytes {
                // CommonCrypto
                // extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md) --|
                // OpenSSL                                                                          |
                // unsigned char *MD5(const unsigned char *d, size_t n, unsigned char *md)        <-|
                CC_MD5($0.baseAddress, UInt32(strData.count), &digest)
            }
     
     
            var md5String = ""
            /// Unpack each byte in the digest array and add them to the md5String
            for byte in digest {
                md5String += String(format:"%02x", UInt8(byte))
            }
     
            // MD5 hash check (This is just done for example)
            if md5String.uppercased() == "8D84E6C45CE9044CAE90C064997ACFF1" {
               // print("Matching MD5 hash: 8D84E6C45CE9044CAE90C064997ACFF1")
            } else {
               // print("MD5 hash does not match: \(md5String)")
            }
            return md5String
     
        }
        return ""
    }
}



extension Data {

    init?(fromHexEncodedString string: String) {

        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }

        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
}


extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}



/*    let password = "UserPassword1!"
    let key256   = "12345678901234561234567890123456"   // 32 bytes for AES256
 //   let iv       = "abcdefghijklmnop" // 16 bytes for AES128
    
    var iv = "abcdefghijklmnopdjhhfkjhdjkjfkhds" // 16 bytes for AES128

    iv =   iv.md5Hash(str: iv)
    
    
   // iv = iv.hexToString()
    
    let base64ReadableKey = iv.base64Decoded() ?? ""

    print(base64ReadableKey)
    let aes256 = AES(key: key256, iv: iv)
    let encryptedPassword256 = aes256?.encrypt(string: password)
    print(aes256?.decrypt(data: encryptedPassword256))

*/


/*

func showPasswordEnter(text:String) {

    let password = "UserPassword1!"
    let iv = "abcdefghijklmnop"
    let key256 =   "".md5Hash(str: "pp")
    let aes256 = AES(key: key256, iv: iv)
    let encryptedPassword256 = aes256?.encrypt(string: password)
    let strBase64 = encryptedPassword256!.base64EncodedString()
    print (strBase64)
    testingss(str: strBase64)
}

func testingss(str:String) {
    
    let iv = "abcdefghijklmnop"
    let key256 =   "".md5Hash(str: "pp")
    let aes256 = AES(key: key256, iv: iv)
    let data = Data(base64Encoded: str, options: .ignoreUnknownCharacters)
    let decryptedValue = aes256?.decrypt(data: data)
    print(decryptedValue)
}
*/

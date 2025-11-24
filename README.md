### Usage

```swift

Meraki.networkId = "MY-NETWORK-ID"
 Meraki.keysFetcher = {
     // Get from Secrets; eventually from DB
     Credentials(
         apiKey: "MY-API-KEY"
     )
 }
 
 let devices = try await Device.list()
 print("devices", devices.count)
 
 let filtered = try await Device.get(serials: ["SERIAL1", "SERIAL2", "SERIAL3"])
 print("filtered", filtered)
 
 for device in filtered {
     print("lockedUsername: \(device.lockedUsername ?? "-")")
 }

```

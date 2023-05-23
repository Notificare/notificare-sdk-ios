//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareKit
import OSLog
import SwiftUI

struct ScannablesView: View {
    var body: some View {
        List {
            Section {
                VStack {
                    Button(String(localized: "scannables_nfc")) {
                        Logger.main.info("NFC scan clicked")
                        Notificare.shared.scannables().startNfcScannableSession()
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                    .disabled(!Notificare.shared.scannables().canStartNfcScannableSession)

                    Divider()

                    Button(String(localized: "scannables_qr_code")) {
                        Logger.main.info("QR Code scan clicked")
                        guard let rootViewController = UIApplication.shared.rootViewController else {
                            return
                        }

                        Notificare.shared.scannables().startQrCodeScannableSession(controller: rootViewController, modal: true)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            } header: {
                Text(String(localized: "scannables_scannable_session"))
            }
        }
        .navigationTitle(String(localized: "scannables_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScannablesView_Previews: PreviewProvider {
    static var previews: some View {
        ScannablesView()
    }
}

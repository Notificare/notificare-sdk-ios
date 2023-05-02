//
// Copyright (c) 2023 Notificare. All rights reserved.
//

import NotificareInboxKit
import NotificareKit
import SwiftUI

struct InboxItemView: View {
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        return formatter
    }()

    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        return formatter
    }()

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    let item: NotificareInboxItem

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Group {
                if let urlStr = item.notification.attachments.first?.uri, let url = URL(string: urlStr) {
                    AsyncImageCompat(url: url) { image in
                        Image(uiImage: image)
                            .resizable()
                    } placeholder: {
                        imagePlaceholder
                    }
                } else {
                    imagePlaceholder
                }
            }
            .frame(width: 48, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 0) {
                if let title = item.notification.title {
                    Text(verbatim: title)
                        .font(.headline)
                        .lineLimit(1)
                }

                Text(verbatim: item.notification.message)
                    .font(.caption)
                    .lineLimit(item.notification.title == nil ? 2 : 1)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
                    .opacity(item.opened ? 0 : 1)

                Spacer()

                Text(verbatim: formattedTime)
                    .font(.footnote)
            }
        }
    }

    private var imagePlaceholder: some View {
        Group {
            if colorScheme == .light {
                Color.black.opacity(0.05)
            } else {
                Color.white.opacity(0.15)
            }
        }
    }

    private var formattedTime: String {
        if Calendar.current.isDateInToday(item.time) {
            return InboxItemView.timeFormatter.string(from: item.time)
        }

        return InboxItemView.dateFormatter.string(from: item.time)
    }
}

struct InboxItemView_Previews: PreviewProvider {
    static var previews: some View {
        let item = NotificareInboxItem(
            id: UUID().uuidString,
            notification: NotificareNotification(
                partial: false,
                id: UUID().uuidString,
                type: "re.notifica.notification.Alert",
                time: Date(),
                title: "Hello world",
                subtitle: "SwiftUI rocks! 🤘",
                message: "Lorem ipsum",
                content: [],
                actions: [],
                attachments: [
                    NotificareNotification.Attachment(
                        mimeType: "image/jpeg",
                        uri: "https://push.notifica.re/asset/file/aad066ca10a9ced782194be1774553c517f0953857f1a55d3c54e0adcac2e0ec/a64254c0b032a36fc9bf40f695481f9dca333e5a7fcd75842228ce0b4aa4fa09"
                    ),
                ],
                extra: [:],
                targetContentIdentifier: nil
            ),
            // time: Date(),
            time: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            opened: false,
            expires: nil
        )

        List {
            InboxItemView(item: item)
        }

        List {
            InboxItemView(item: item)
        }
        .preferredColorScheme(.dark)
    }
}

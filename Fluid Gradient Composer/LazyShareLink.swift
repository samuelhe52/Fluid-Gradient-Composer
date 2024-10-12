//
//  LazyShareLink.swift
//  Fluid Gradient Composer
//
//  Created by Samuel He on 2024/10/3.
//

import SwiftUI

struct LazyShareLink: View {

    let text: LocalizedStringKey
    let prepareData: () -> [Any]?

    init(_ text: LocalizedStringKey = "Share", prepareData: @escaping () -> [Any]?) {
        self.text = text
        self.prepareData = prepareData
    }

    var body: some View {
        Button(action: openShare) {
            Label(text, systemImage: "square.and.arrow.up")
        }
    }

    private func openShare() {
        guard let data = prepareData() else {
            return
        }
        let activityVC = UIActivityViewController(activityItems: data, applicationActivities: nil)

        if UIDevice.current.userInterfaceIdiom == .pad {
            // otherwise iPad crashes
            let thisViewVC = UIHostingController(rootView: self)
            activityVC.popoverPresentationController?.sourceView = thisViewVC.view
        }

        UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .present(activityVC, animated: true, completion: nil)
    }
}

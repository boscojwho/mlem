//
//  MediaPreviewViewController.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-09-02.
//

import UIKit
import QuickLook

final class MediaPreviewViewController: QLPreviewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add overlay on top of QuickLookUI.
//        let overlay = UIView(frame: .init(origin: .init(x: 100, y: 500), size: .init(width: 100, height: 100)))
//        overlay.backgroundColor = .purple
//        view.addSubview(overlay)
    }
}

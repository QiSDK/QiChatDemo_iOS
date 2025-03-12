//
//  KeFuViewController_FilePicker.swift
//  Pods
//
//  Created by XiaoFu on 3/3/25.
//

import UIKit
import MobileCoreServices

extension KeFuViewController: UIDocumentPickerDelegate {
    

    @objc func openDocumentPicker() {
        // Define the allowed file types
        let allowedFileTypes = [
            kUTTypePDF,          // PDF files
            kUTTypeRTF,          // Rich Text Format (Word documents)
            kUTTypePlainText,    // Plain text files
            kUTTypeSpreadsheet,  // Excel files
            kUTTypePresentation
        ] as [String]
        
        // Create a document picker for all file types
         documentPicker = UIDocumentPickerViewController(documentTypes: allowedFileTypes, in: .open)
         //let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeData)], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Set to true if you want to allow multiple file selection
        present(documentPicker, animated: true, completion: nil)
       }
    
        // Called when the user selects a file
    public  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            print("No file selected")
            return
        }
        controller.dismiss(animated: true)
        
        /*var ext = selectedFileURL.absoluteString.split(separator: ".")
        
        //是目录，开始下载
        if ext.count == 1{
            if selectedFileURL.startAccessingSecurityScopedResource() {
                defer { selectedFileURL.stopAccessingSecurityScopedResource() }
                // Handle the selected file
                self.startToDownload(imgUrl: downloadFile ?? "#", toDirectory: selectedFileURL);
            }else {
                print("Could not access 所选择的目录")
                documentPicker.dismiss(animated: true)
            }
        }else{*/
            handleSelectedFile(selectedFileURL)
        //}
    }

        // Called when the user cancels the file picker
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("File picker was cancelled")
        controller.dismiss(animated: true)
        }

    private func handleSelectedFile(_ fileURL: URL) {
        // Access the file URL
        print("Selected file URL: \(fileURL)")
    
        // Example: Read the file name
        let fileName = fileURL.lastPathComponent
        print("File name: \(fileName)")
        
        if fileURL.startAccessingSecurityScopedResource() {
            defer { fileURL.stopAccessingSecurityScopedResource() }
            do {
                let fileData = try Data(contentsOf: fileURL)
                self.upload(imgData: fileData, isVideo: false, filePath: fileName, size: Int32(fileData.count))
            
                print("File data loaded successfully")
            } catch {
                print("Failed to read file data: \(error.localizedDescription)")
                documentPicker.dismiss(animated: true)
            }
        } else {
            print("Could not access file URL")
            documentPicker.dismiss(animated: true)
        }
        
//        guard let localUrl = copyFileToLocal(from: fileURL) else {
//            print("Unable to get file data")
//            WWProgressHUD.showInfoMsg("读取文件数据失败")
//            return
//        }
//        
//        // Example: Read the file content
//        guard let fileData = try? Data(contentsOf: localUrl) else {
//            print("Unable to get file data")
//            WWProgressHUD.showInfoMsg("获取文件数据失败")
//            return
//        }
//
    }
    
    func copyFileToLocal(from fileURL: URL) -> URL? {
        let fileManager = FileManager.default
        let tempDir = FileManager.default.temporaryDirectory
        let destinationURL = tempDir.appendingPathComponent(fileURL.lastPathComponent)

        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Error copying file: \(error.localizedDescription)")
            return nil
        }
    }

}

//
//  ConversationVC.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class ConversationVC: UIViewController, UITableViewDelegate, ConversationViewModelDelegate, UITextFieldDelegate {

    // MARK:- Interface Builder outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!

    // MARK:- Properties
    var conversationSid: String = ""

    private var conversationViewModel: ConversationViewModel!
    private var initialLoad = false

    // MARK:- UIViewController
    override func viewDidLoad() {
        guard !conversationSid.isEmpty else {
            showUnableToLoadConversationAlert()
            return
        }
        setupKeyboardListener()
        registerXIB()
        messageTextField.delegate = self
        tableView.delegate = self
        conversationViewModel = ConversationViewModel(conversationSid: conversationSid)
        conversationViewModel.delegate = self
        tableView.dataSource = conversationViewModel
        tableView.separatorStyle = .none
        conversationViewModel.loadConversation()
    }

    private func registerXIB() {
        tableView.register(UINib(nibName:MessagesTableCellViewType.outgoingMessage.rawValue, bundle: nil),
                           forCellReuseIdentifier: MessagesTableCellViewType.outgoingMessage.rawValue)
        tableView.register(UINib(nibName: MessagesTableCellViewType.incomingMessage.rawValue, bundle: nil),
                           forCellReuseIdentifier: MessagesTableCellViewType.incomingMessage.rawValue)
        tableView.register(UINib(nibName: MessagesTableCellViewType.typingMemeber.rawValue, bundle: nil),
                           forCellReuseIdentifier:  MessagesTableCellViewType.typingMemeber.rawValue)
        tableView.register(UINib(nibName: MessagesTableCellViewType.outgoingMediaMessage.rawValue, bundle: nil),
                           forCellReuseIdentifier:  MessagesTableCellViewType.outgoingMediaMessage.rawValue)
        tableView.register(UINib(nibName: MessagesTableCellViewType.incomingMediaMessage.rawValue, bundle: nil),
                           forCellReuseIdentifier:  MessagesTableCellViewType.incomingMediaMessage.rawValue)
    }

    func onConversationUpdated() {
        self.title = self.conversationViewModel.observableConversation?.value?.first?.friendlyName
    }

    func messageListUpdated(from: [MessageListItemCell], to: [MessageListItemCell]) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if from.count < to.count {
                self.tableView.scrollToRow(at: IndexPath(item: to.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }

    func onDisplayError(_ error: Error) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: NSLocalizedString("Error", comment: "Alert title message for occured error"), message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledgment that this error message was read"), style: .default))
            self.present(ac, animated: true)
        }
    }

    private func sendMessage() {
        guard let text = messageTextField.text else {
            return
        }
        conversationViewModel.sendMessage(message: text)
        messageTextField.text = ""
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToConversationDetails", let destinationVC = segue.destination as? ConversationDetailsVC {
            destinationVC.conversationSid = self.conversationSid
        }
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMessage()
        return true
    }

    @IBAction func onTextChange(_ sender: Any) {
        conversationViewModel.notifyTypingOnConversation(conversationSid)
    }

    @IBAction func onSendMessagePressed(_ sender: UIButton) {
        sendMessage()
    }

    @IBAction func onMediaButtonPressed(_ sender: Any) {
        let ac = UIAlertController(title: "Choose Media", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Media Library", style: .default) { _ in
            self.openMediaLibrary(mediaSourceType: .photoLibrary)
        })
        ac.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            self.openMediaLibrary(mediaSourceType: .camera)
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    func openMediaLibrary(mediaSourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(mediaSourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = mediaSourceType
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }



    // MARK:- setupKeyboardListener
    func setupKeyboardListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    func onDisplayAddReactionModal(withMessage message: MessageDataListItem) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "AddReactionViewController") as! AddReactionVC
        vc.loadViewIfNeeded()
        vc.delegate = self
        vc.setMessage(withMessage: message)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }

    func onDisplayReactionList(forReaction reactionType: String, onMessage messageSid: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ReactionListVC") as! ReactionListVC
        vc.messageSid = messageSid
        vc.reactionType = reactionType
        navigationController?.pushViewController(vc, animated: true)
    }

    func showFullScreenImage(mediaSid: String, imageUrl: URL) {
        let imagePreviewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImagePreviewVC") as! ImagePreviewVC
        imagePreviewVC.imageURL = imageUrl
        imagePreviewVC.mediaSid = mediaSid
        imagePreviewVC.modalPresentationStyle = .fullScreen
        imagePreviewVC.modalTransitionStyle = .coverVertical
        navigationController?.pushViewController(imagePreviewVC, animated: true)
    }

    private func showUnableToLoadConversationAlert() {
        let dialogTitle = NSLocalizedString("Could not load conversation", comment: "Could not load the conversation")
        let dialogMessage = NSLocalizedString("Unable to find this conversation", comment: "Could not load the conversation")
        let alert = UIAlertController(title: dialogTitle, message: dialogMessage, preferredStyle: .alert)
        let actionTitle = NSLocalizedString("Back to conversations list", comment: "Allow user to go back to the conversation list screen")
        let backToConversationListAction = UIAlertAction(title: actionTitle , style: .default) { action in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(backToConversationListAction)
        self.present(alert, animated: true)
    }

    func onMessageLongPressed(_ message: MessageDataListItem) {
        let dialogTitle = NSLocalizedString("Choose action", comment: "Choose action on message dialog title")
        let ac = UIAlertController(title: dialogTitle, message: nil, preferredStyle: .actionSheet)
        let messageActions = self.conversationViewModel.getActionOnMessage(message)
        addActionsToAlertController(ac: ac, onMessage: message, actions: messageActions)
        present(ac, animated: true)
    }

    private func addActionsToAlertController(ac: UIAlertController, onMessage message: MessageDataListItem,actions: [MessageAction]) {
        for action in actions {
            var alertAction: UIAlertAction!
            switch action {
            case .edit:
                let editMessageActionTitle = NSLocalizedString("Edit message", comment: "Edit Message")
                alertAction = UIAlertAction(title: editMessageActionTitle, style: .default)
            case .react:
                let addReactionActionTitle = NSLocalizedString("Add reaction", comment: "Add reaction to this message")
                alertAction = UIAlertAction(title: addReactionActionTitle, style: .default) { _ in
                    self.onDisplayAddReactionModal(withMessage: message)
                }
            case .remove:
                let addReactionActionTitle = NSLocalizedString("Remove message", comment: "Remove message")
                alertAction = UIAlertAction(title: addReactionActionTitle, style: .destructive) { _ in
                    self.removeMessage(message)
                }
            }
            ac.addAction(alertAction)
        }
        let cancelActionTitle = NSLocalizedString("Cancel", comment: "Cancel")
        ac.addAction(UIAlertAction(title: cancelActionTitle, style: .cancel))
    }

    private func removeMessage(_ message: MessageDataListItem) {
        self.conversationViewModel.deleteMessage(message)
    }

}

extension ConversationVC: ReactionDelegate {
    func onReactionSelected(reaction: ReactionType, for messageSid: String) {
        self.conversationViewModel.reactToMessage(withReaction: reaction, forMessageSid: messageSid)
    }
}


extension ConversationVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if (picker.sourceType == .photoLibrary) {
            sendMediaMessageFromLibrary(info: info)
        }
        if (picker.sourceType == .camera) {
            sendMediaMessageFromCamera(info: info)
        }
    }

    private func sendMediaMessageFromLibrary(info: [UIImagePickerController.InfoKey : Any]) {
        guard
            let url = info[.imageURL] as? URL,
            let mimeType = url.associatedMimeType,
            let urlData = try? Data(contentsOf: url)
        else {
            return
        }
        let inputStream = InputStream(data: urlData)
        conversationViewModel.sendMediaMessage(inputStream: inputStream, mimeType: mimeType, inputSize: urlData.count)
    }

    private func sendMediaMessageFromCamera(info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
              let imgData = image.jpegData(compressionQuality: 0.9) else {
            return
        }
        let inputStream = InputStream(data: imgData)
        conversationViewModel.sendMediaMessage(inputStream: inputStream, mimeType: "jpeg", inputSize: imgData.count)
    }

}

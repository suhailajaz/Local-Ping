//
//  ViewController.swift
//  Project25-Selfie Share
//
//  Created by suhail on 29/08/23.
//
import MultipeerConnectivity
import UIKit

class ViewController: UIViewController {
    
    
    
    var images = [UIImage]()
    var text = ""
    @IBOutlet var lblCipherText: UILabel!
    var peerId =  MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    
    
    
    @IBOutlet var col: UICollectionView!{
        didSet{
            self.col.register(PictureCollectionViewCell.nib, forCellWithReuseIdentifier: PictureCollectionViewCell.identifier)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Selfie Share"
        let connect = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        let checkHowMany = UIBarButtonItem(title: "Devices", style: .plain, target: self, action: #selector(checkConnections))
        navigationItem.leftBarButtonItems = [connect,checkHowMany]
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        let textBtn = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(sendText))
        navigationItem.rightBarButtonItems = [textBtn,camera]
        col.dataSource = self
        col.delegate = self
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    @objc func checkConnections(){
        guard let mcSession = mcSession else { return }
        let connection = mcSession.connectedPeers.description
        let ac = UIAlertController(title: "connectedPeers", message: connection, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(ac, animated: true)
        
        
    }
}


extension ViewController: UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PictureCollectionViewCell.identifier, for: indexPath) as! PictureCollectionViewCell
        //        if let imgView = cell.viewWithTag(20) as? UIImageView {
        //            imgView.image = images[indexPath.row]
        //        }
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item<3 || indexPath.item>6{
            return CGSize(width: (col.bounds.width/3)-14, height: (col.bounds.width/3)-14)
        }else{
            return CGSize(width: (col.bounds.width/2)-15, height: (col.bounds.width/2)-15)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "fullScreen") as? DetailViewController{
            vc.currentImage = images[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController:UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate{
    @objc func sendText(){
        let ac = UIAlertController(title: "Enter text", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Send", style: .default,handler: { _ in
            guard let textt = ac.textFields?[0].text else { return }
            self.text = textt
            self.lblCipherText.text = textt
            self.sendTextToPears(message: textt)
        }))
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac,animated: true)
    }
    
    func sendTextToPears(message: String) {
            guard let mcSession = mcSession else { return }
            let textData = Data(message.utf8)
            // 2
            if mcSession.connectedPeers.count > 0 {
                
                if message != "" {
                    do {
                       
                        try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                    } catch {
                        // 5
                        let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        present(ac, animated: true)
                    }
                }
                
            }
        }
    
    @objc func importPicture(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker,animated: true)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        dismiss(animated: true)
        images.append(image)
        //images.insert(image, at: 0)
        col.reloadData()
        
        //sending the image to other users in the session
        guard let mcSession = mcSession else {return}
        if mcSession.connectedPeers.count>0{
            if let imgData = image.pngData(){
                do{
                    try mcSession.send(imgData, toPeers: mcSession.connectedPeers, with: .reliable)
                }catch{
                    let ac = UIAlertController(title: "An error occured!", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .default))
                    present(ac,animated: true)
                }
            }
        }
    }
}

extension ViewController: MCSessionDelegate,MCBrowserViewControllerDelegate,MCNearbyServiceAdvertiserDelegate{
   
    @objc func showConnectionPrompt(){
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a Session", style: .default,handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a Session", style: .default,handler: joinSession))
        ac.addAction((UIAlertAction(title: "Cancel", style: .cancel)))
        present(ac,animated: true)
    }
    func startHosting(action: UIAlertAction){
        // guard let mcSession = mcSession else { return}
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: "hws-project25")
       // mcAdvertiserAssistant?.start()
        mcAdvertiserAssistant.delegate = self
        mcAdvertiserAssistant.startAdvertisingPeer()
        
        let ac = UIAlertController(title: "New session created!!", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac,animated: true)
        
    }
    func joinSession(action: UIAlertAction){
        guard let mcSession = mcSession else { return}
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser,animated: true)
        
    }
    //MCSessionDelegate protocol methods
    //main method that triggers when it recives some data from any other device in the session
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async{[weak self] in
            //handlig image data
            if let image = UIImage(data: data){
                self?.images.append(image)
                self?.col.reloadData()
            }else{
                var textte = String(decoding: data, as: UTF8.self)
                if textte != ""{
                        self?.lblCipherText.text = textte
                }
            }
            //handling string text
//            var textte = String(decoding: data, as: UTF8.self)
//            if textte != ""{
//                if textte.hasPrefix("###"){
//                    textte.trimPrefix("###")
//                    self?.lblCipherText.text = textte
//                }
//
//            }
            
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    //MCBrowserViewControllerDelegate protocols
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    //diagnostic method
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            let ac = UIAlertController(title: "User lost!", message: "\(peerID.displayName)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac,animated: true)
        @unknown default:
            print("Unknown state recieved: \(peerID.displayName)")
        }
        
    }
    //MCNearbyServiceAdvertiser delegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
            invitationHandler(true, mcSession)
        }
}

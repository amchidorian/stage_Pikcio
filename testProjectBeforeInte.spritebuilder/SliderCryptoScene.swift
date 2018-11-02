//
//  SliderCryptoScene.swift
//  ze iOS
//
//  Created by Dorian Pikcio on 24/10/2018.
//  Copyright © 2018 Apportable. All rights reserved.
//

import Foundation

class SliderCryptoScene: CCNode, CCScrollViewDelegate {
    
    //Variable locale
    var lDataCrypto:Array<[String:Any]>! = []
    var lDataCryptoAlphabet:Array<[String:Any]>! = []
    var lTemplateCrypto:[String:Any]!
    var lSlider:CCNode!
    var lItemCryptoList:CCNode! = CCBReader.load("ItemCrypto")
    var lItemCryptoGrid:CCNode! = CCBReader.load("ItemCryptoGrid")
    var lNbItemOnSlider:CGFloat = 100
    var lItemHeight:CGFloat!
    var lOptions:Bool = true
    
    //Variable Design
    weak var _crypto1: CCNode!
    weak var _optionsNode:CCNode!
    weak var _scrollViewCrypto:CCScrollView!
    weak var _alphaPlain:CCSprite!
    weak var _favPlain:CCSprite!
    weak var _gridItem:CCSprite!
    weak var _listItem:CCSprite!
    weak var _deviseLabel:CCLabelTTF!
    
    // Variable Static
    static var sAlphabet:Bool = false
    static var sDollars:Bool = true
    static var sList:Bool = true
    static var sFav:Bool = false

    static let sTotalCrypto:Int = 100

    // Function appelé au chargement de la scene
    func didLoadFromCCB(){
        _scrollViewCrypto.delegate = self
        let parentSlider:[CCNode]! = (_scrollViewCrypto!.children as? [CCNode])
        lSlider = parentSlider[0]
        for _ in 0..<SliderCryptoScene.sTotalCrypto{lDataCrypto.append([:])}
        for _ in 0..<SliderCryptoScene.sTotalCrypto{lDataCryptoAlphabet.append([:])}
        organizeCryptoDatas()
        alphabeticSort()
        createSlider()
    }
    
    // Function appelé lorsque l'on appuie sur le bouton pour avoir dans l'ordre alphabétic
    func alphaView(){
        SliderCryptoScene.sAlphabet = !SliderCryptoScene.sAlphabet
        if SliderCryptoScene.sAlphabet {
            _alphaPlain.opacity = 0.8
        } else {
            _alphaPlain.opacity = 0.5
        }
       createSlider()
    }

    // Function qui détecte quand la scroll bouge et qui en fonction de la position affiche ou non le panneau d'options.
    func scrollViewDidScroll(_ _scrollViewCrypto: CCScrollView!) {
        let lScrollPositionY = _scrollViewCrypto.scrollPosition.y;
        if lOptions {
            if lScrollPositionY > 620 {
                _optionsNode.animationManager.runAnimations(forSequenceNamed: "hideOptions")
                lOptions = !lOptions
            }
        }
        if !lOptions {
            if lScrollPositionY < 600 {
                _optionsNode.animationManager.runAnimations(forSequenceNamed: "displayOptions")
                lOptions = !lOptions
            }
        }
    }
    
    // Fonction appelé lorsque l'on clique sur le bouton pour passer de la vue en List à la vue en Grid et inversement.
    func changeView(){
        SliderCryptoScene.sList = !SliderCryptoScene.sList
        lNbItemOnSlider = SliderCryptoScene.sList ? CGFloat(SliderCryptoScene.sTotalCrypto) : ceil(CGFloat(SliderCryptoScene.sTotalCrypto/3))
        createSlider()
    }
    
    // Fonction appelé lorsque l'on clique sur le bouton pour changer de devise.
    func changeDevise(){
        SliderCryptoScene.sDollars = !SliderCryptoScene.sDollars
        _deviseLabel.string = SliderCryptoScene.sDollars ? "€" : "$"
        createSlider()
    }
    
    // Fonction appelé lorsque l'on clique sur une crypto pour accéder à ses détails.
    func detailView(_ pSender:CCButton){
        let lIndexData = (Int(pSender.name!)!) - 1
        DetailCrypto.sDataCrypto = lDataCrypto[lIndexData]
        let lGameplayScene = CCBReader.load(asScene:"DetailCrypto")
        let lTransition = CCTransition(fadeWithDuration: 1.0)
        CCDirector.shared().present(lGameplayScene, with: lTransition)
    }
    
    // Fonction qui créer le slider.
    func createSlider(){
        lSlider.removeAllChildren()
        lItemHeight = SliderCryptoScene.sList ? lItemCryptoList.contentSize.height : lItemCryptoGrid.contentSize.height
        lSlider.contentSize.height = lItemHeight * lNbItemOnSlider
        if SliderCryptoScene.sList {
            createSliderList()
        } else {
            createSliderGrid()
        }
    }

    // Fonction qui crée le slider pour la liste.
    func createSliderList(){
        for i in 0..<lDataCrypto.count{
            let lItem:CCNode = CCBReader.load("ItemCrypto")
            lItem.position = CGPoint.init(x: 0, y: lItemHeight * lNbItemOnSlider - lItemHeight * CGFloat(i+1))
            let lItemChildren:Array = lItem.children
            for lObj in lItemChildren {
                editItem(lObj, i)
            }
            lSlider.addChild(lItem)
        }
    }

    // Fonction qui crée le slider pour la grid.
    func createSliderGrid(){
        var lPosIndex = 0;
        for i in stride(from: 0, to: lDataCrypto.count, by: 3) {
            var lTempi = i
            let lItem:CCNode = CCBReader.load("ItemCryptoGrid")
            lItem.position = CGPoint.init(x: 0, y: lItemHeight * ceil(CGFloat(SliderCryptoScene.sTotalCrypto/3)) - lItemHeight * CGFloat(lPosIndex+1))
            let lItemChildrens:Array = lItem.children
            for lItemChildren in lItemChildrens {
                print(lTempi)
                if lTempi + 1 > lDataCrypto.count {
                    print("error")
                    (lItemChildren as! CCNode).visible = false
                } else {
                    let lItemChildrenChildrens:Array = (lItemChildren as! CCNode).children
                    for lItemChildrenChildren in lItemChildrenChildrens {
                        editItem(lItemChildrenChildren, lTempi)
                    }
                    lTempi = lTempi+1
                }
            }
            lSlider.addChild(lItem)
            lPosIndex = lPosIndex + 1
        }
    }
    
    // Fonction qui créer un item du slider.
    func editItem(_ lElement:Any, _ lIndex:Int){
        var lCryptoData = SliderCryptoScene.sAlphabet ? lDataCryptoAlphabet![lIndex] : lDataCrypto![lIndex]
        if let sprite = lElement as? CCSprite {
            if sprite.name.elementsEqual("light") {
                let img = sprite.children[0] as! CCSprite
                img.spriteFrame = CCSpriteFrame.init(imageNamed: "coinMarketCap/\(lCryptoData["img"]!)")
            }
        }
        if let colorNode = lElement as? CCNodeColor {
            colorNode.color = CCColor(uiColor: UIColor(red: 40/255.0, green: 53/255.0, blue: 61/255.0, alpha: 1.0));
        }
        if let btn = lElement as? CCButton {
            btn.name = "\(lCryptoData["rank"]!)";
            btn.setTarget(self, selector: #selector(detailView))
        }
        if let label = lElement as? CCLabelTTF {
            if label.name.elementsEqual("cryptoName") {
                label.string = "\(lCryptoData["name"]!)"
            }
            if label.name.elementsEqual("shortName") {
                label.string = "\(lCryptoData["symbol"]!)"
            }
            if label.name.elementsEqual("value") {
                let lPrice = SliderCryptoScene.sDollars ? lCryptoData["price"]! : (lCryptoData["price"]! as! CGFloat) * CGFloat(0.88)
                label.string = SliderCryptoScene.sDollars ? "$ \(lPrice)" : "\(lPrice) €"
            }
            if label.name.elementsEqual("percent") {
                let floatPercent = (lCryptoData["change7"]! as! NSNumber).floatValue
                label.string = "\(floatPercent)"
                if floatPercent > 0 {
                    label.color = CCColor(uiColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1.0));
                } else if floatPercent < 0 {
                    label.color = CCColor(uiColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1.0));
                }
            }
        }
    }
    
    // Function to create array of data
    func organizeCryptoDatas(){
        let lCryptoDatas = unwrapJson(HttpRequest.sCryptoDataParsed!["data"]!)
        for(_,lValue) in lCryptoDatas {
            self.lTemplateCrypto = [:]
            let lCryptoData = unwrapJson(lValue)
            organizeCryptoData(lCryptoData)
            let lIndex = ((lTemplateCrypto["rank"] as? Int)!) - 1
            lTemplateCrypto["img"] = "\(lTemplateCrypto["name"]!).png"
            lDataCrypto![lIndex] = self.lTemplateCrypto!
        }
    }
    
    // Fonction qui organise une data avant de l'insérer dans le tableau.
    func organizeCryptoData(_ pCryptoData:NSDictionary){
        for(key,lValue) in pCryptoData {
            let jsonKey = key as? String
            switch jsonKey {
            case "rank":
                self.lTemplateCrypto["rank"] = lValue
                break
            case "name":
                self.lTemplateCrypto["name"] = lValue
                break
            case "symbol" :
                self.lTemplateCrypto["symbol"] = lValue
                break
            case "total_supply" :
                self.lTemplateCrypto["total"] = lValue
                break
            case "price" :
                self.lTemplateCrypto["price"] = lValue
                break
            case "percent_change_7d" :
                self.lTemplateCrypto["change7"] = lValue
                break
            case "percent_change_24h" :
                self.lTemplateCrypto["change24"] = lValue
                break
            case "percent_change_1h" :
                self.lTemplateCrypto["change1"] = lValue
                break
            case "quotes" :
                let lTempData = unwrapJson(lValue)
                organizeCryptoData(lTempData)
                break
            case "USD" :
                let lTempData = unwrapJson(lValue)
                organizeCryptoData(lTempData)
                break
            default:
                break
            }
        }
    }
    
    // Fonction pour unwrap un JSON
    func unwrapJson(_ pData:Any) -> NSDictionary{
        if let lDataToReturn = pData as? NSDictionary {
            return lDataToReturn
        } else {
            return [:]
        }
    }
    
    // Function to alpha sort crypto data
    func alphabeticSort(){
        lDataCryptoAlphabet = lDataCrypto
        lDataCryptoAlphabet.sort {
            let lDataCryptoAlphabetA = ($0.0["name"] as! String).lowercased()
            let lDataCryptoAlphabetB = ($0.1["name"] as! String).lowercased()
            
            return lDataCryptoAlphabetA < lDataCryptoAlphabetB
        }
    }
    
}

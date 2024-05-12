//
//  BattleViewController.swift
//  TechMon
//
//  Created by chick on 2024/05/11.
//

import UIKit

class BattleViewController: UIViewController {
    
    @IBOutlet var playerNameLabel: UILabel!
    @IBOutlet var playerImageView: UIImageView!
    @IBOutlet var playerHPBar: UIProgressView!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var enemyHPBar: UIProgressView!
    @IBOutlet var playerTPLabel: UILabel!
    
    var player: Player!
    var enemy: Enemy!
    
    var enemyAttackTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 標準だとProgressViewが細いので拡大
        playerHPBar.transform = CGAffineTransform (scaleX: 1.0, y: 4.0)
        enemyHPBar.transform = CGAffineTransform (scaleX: 1.0, y: 4.0)
        // プレイヤーと敵のステータスを設定
        player = Player (name: "勇者", imageName: "yusya.png", attackPoint: 20, maxHP:100)
        enemy = Enemy(name: "ドラゴン ", imageName: "monster.png", attackPoint: 10, maxHP:300)
        // プレイヤーのステータスを反映
        playerNameLabel.text = player.name
        playerImageView.image = player.image
        // 敵のステータスを反映
        enemyNameLabel.text = enemy.name
        enemyImageView.image = enemy.image

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear (animated)
        
        // BGMを開始
        TechMonManager.playBGM (fileName: "BGM_battle001")
        //敵の自動攻撃
        enemyAttackTimer = Timer.scheduledTimer(
            timeInterval: 1.5,
            target: self,
            selector: #selector(enemyAttack),
            userInfo: nil,
            repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear (animated)
        
        // BGMを止める
        TechMonManager.stopBGM()
    }
    
    //画面の表示を更新
    func updateUI() {
        //プレイヤーのステータスを反映
        playerHPBar.progress = player.currentHP / player.maxHP
        //てきのステータスを反映
        enemyHPBar.progress = enemy.currentHP / enemy.maxHP
    }
    
    // 勝敗が決定した時の処理
    func finishBattle (vanishImageView: UIImageView, isPlayerWin: Bool) {
        TechMonManager.vanishAnimation (imageView: vanishImageView)
        TechMonManager.stopBGM()
        enemyAttackTimer.invalidate()
        
        var finishMessage: String = ""
        if isPlayerWin {
            TechMonManager.playSE (fileName: "SE_fanfare")
            finishMessage = "勇者の勝利!!"
        } else {
            TechMonManager.playSE (fileName: "SE_gameover")
            finishMessage = ".勇者の敗北…"
        }
        
        let alert = UIAlertController(
            title: "L",
            message: finishMessage,
            preferredStyle: .alert)
        alert.addAction (UIAlertAction(title: "OK", style: .default, handler: { _ in self.dismiss(animated: true)
        }))
        present (alert, animated: true)
    }
    
    //プレイヤーの攻撃
    @IBAction func attackAction() {
        TechMonManager.damageAnimation (imageView: enemyImageView)
        TechMonManager.playSE(fileName: "SE_attack")
        //敵がダメージ受ける
        enemy.currentHP -= player.attackPoint
        
        // TP tameru
        player.currentTP += 10
        if player.currentTP >= player.maxTP {
            player.currentTP = player.maxTP
        }
        updateUI()
        // プレイヤーの勝利
        if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    //tameru
    @IBAction func chargeAction() {
        TechMonManager.playSE(fileName: "SE_charge")
        
        player.currentTP += 20
            if player.currentTP >= player.maxTP {
            player.currentTP = player.maxTP
            
        }
        updateUI()
    }
    // ファイア
    @IBAction func fireAction () {
        if player.currentTP >= player.maxTP {
            TechMonManager.damageAnimation (imageView: enemyImageView)
            TechMonManager.playSE (fileName: "SE_fire")
            // ファイアでダメージを与える
            enemy.currentHP -= player.fireAttackPoint
            player.currentTP = 0
        }
        updateUI()
        // プレイヤーの勝利
        if enemy.currentHP <= 0 {
            finishBattle (vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    //敵の攻撃
    @objc func enemyAttack() {
        TechMonManager.damageAnimation (imageView: playerImageView)
        TechMonManager.playSE(fileName: "SE_attack")
        //敵からダメージを受ける
        player.currentHP -= enemy.attackPoint
        updateUI()
        // プレイヤーの敗北
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        }
    }
  
}

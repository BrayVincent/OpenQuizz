//
//  ViewController.swift
//  OpenQuizz
//
//  Created by Vincent BRAY on 31/03/2018.
//  Copyright © 2018 Vincent BRAY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var questionView: QuestionView!
    @IBOutlet weak var selectedDifficult: UISegmentedControl!
    
    var game = Game()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name(rawValue: "QuestionsLoaded")
        NotificationCenter.default.addObserver(self, selector: #selector(questionsLoaded), name: name, object: nil)
        
        startNewGame()
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragQuestionView(_:)))
        questionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func questionsLoaded() {
        activityIndicator.isHidden = true
        newGameButton.isHidden = false
        selectedDifficult.isHidden = true
        
        questionView.title = game.currentQuestion.title
    }
    
    @IBAction func didTapNewGameButton() {
        startNewGame()
    }
    
    @IBAction func didSelectedDifficult() {
        
    }
    
    
    private func startNewGame() {
        activityIndicator.isHidden = false
        newGameButton.isHidden = true
        selectedDifficult.isHidden = false
        
        questionView.title = "Loading..."
        questionView.style = .standard
        // Remise à zero des couleurs d'origine
        questionView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        scoreLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.questionView.alpha = 0
        self.scoreLabel.alpha = 0
        // Ajout animation transition au chargement d'une nouvelle partie
        // questionView et scoreLabel avec effet d'apparition
        UIView.animate(withDuration: 2, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.transitionCrossDissolve], animations: {
            self.questionView.alpha = 1
            self.scoreLabel.alpha = 1
        }, completion: nil)
        
        scoreLabel.text = "0 / 10"
        
        game.refresh()
    }

    @objc func dragQuestionView(_ sender: UIPanGestureRecognizer) {
        if game.state == .ongoing {
            switch sender.state {
            case .began, .changed:
                transformQuestionViewWith(gesture: sender)
            case .cancelled, .ended:
                answerQuestion()
            default:
                break
            }
        }
        
    }
    
    private func transformQuestionViewWith(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: questionView)
        let translationTransform = CGAffineTransform(translationX: translation.x, y: translation.y)
        
        let screenWidth = UIScreen.main.bounds.width
        let translationPercent = translation.x / (screenWidth/2)
        let rotationAngle = (CGFloat.pi / 6) * translationPercent
        
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        
        let transform = translationTransform.concatenating(rotationTransform)
        questionView.transform = transform
        
        if translation.x > 0 {
            questionView.style = .correct
        } else {
            questionView.style = .incorrect
        }
    }
    
    private func answerQuestion() {
        switch questionView.style {
        case .correct:
            game.answerCurrentQuestion(with: true)
        case .incorrect:
            game.answerCurrentQuestion(with: false)
        case .standard:
            break
        }
        
        scoreLabel.text = "\(game.score) / 10"
        
        let screenWidth = UIScreen.main.bounds.width
        var translationTransform: CGAffineTransform
        if questionView.style == .correct {
            translationTransform = CGAffineTransform(translationX: screenWidth, y: 0)
        } else {
            translationTransform = CGAffineTransform(translationX: -screenWidth, y: 0)
        }
        
        // modification de la fonction afin d'avoir un effet de transition lors de la levée du doigt
        UIView.animate(withDuration: 0.5, animations: {
            self.questionView.transform = translationTransform
            self.questionView.alpha = 0
        }) { (success) in
            if success {
                self.showQuestionView()
                self.questionView.alpha = 1
            }
        }
    }
    
    private func showQuestionView() {
        questionView.transform = .identity
        questionView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        questionView.style = .standard
        
        switch game.state {
        case .ongoing:
            questionView.title = game.currentQuestion.title
        case .over:
            questionView.title = "Game Over"
            questionView.textColor = #colorLiteral(red: 0.8941176471, green: 0.5490196078, blue: 0.5843137255, alpha: 1)
            // Change couleur police pour signaler la fin de partie
            scoreLabel.textColor = #colorLiteral(red: 0.8941176471, green: 0.5490196078, blue: 0.5843137255, alpha: 1)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.questionView.transform = .identity
        }, completion: nil)
    }
    
}


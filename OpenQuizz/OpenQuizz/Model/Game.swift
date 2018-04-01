//
//  Game.swift
//  OpenQuizz
//
//  Created by Vincent BRAY on 01/04/2018.
//  Copyright © 2018 Vincent BRAY. All rights reserved.
//

import Foundation

class Game {
    var score = 0
    
    private var questions = [Question]()
    private var currentIndex = 0
    
    var state: State = .ongoing
    
    enum State {
        case ongoing, over
    }
    
    var currentQuestion: Question {
        return questions[currentIndex]
    }
    
    func refresh() {
        score = 0
        currentIndex = 0
        state = .over
        
        QuestionManager.shared.get(completionHandler: receiveQuestions(_:))
    }
    
    private func receiveQuestions (_ questions: [Question]) {
        self.questions = questions
        print(questions)
        state = .ongoing
    }
    
    func answerCurrentQuestion(with answer: Bool) {
        if (currentQuestion.isCorrect && answer) || (!currentQuestion.isCorrect && !answer) {
            score += 1
        }
        goToNextQuestion()
    }
    
    private func goToNextQuestion() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            finishGame()
        }
    }
    
    private func finishGame() {
        state = .over
    }
}

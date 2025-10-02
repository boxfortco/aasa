//
//  ParentalGateView.swift
//  BoxFort
//
//  Created by Matthew Ryan on 4/11/25.
//

import SwiftUI

struct ParentalGateView: View {
    @Binding var userAnswer: String
    let completion: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    // Store the numbers for the math problem
    @State private var firstNumber: Int
    @State private var secondNumber: Int
    
    init(userAnswer: Binding<String>, completion: @escaping (Bool) -> Void) {
        self._userAnswer = userAnswer
        self.completion = completion
        
        // Initialize with random numbers
        let first = Int.random(in: 3...12)
        let second = Int.random(in: 3...12)
        self._firstNumber = State(initialValue: first)
        self._secondNumber = State(initialValue: second)
    }
    
    var body: some View {
        ZStack {
            // Background gradient that fills the entire screen
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.5), Color(red: 0.1, green: 0.1, blue: 0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture {
                isTextFieldFocused = false
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("🐴") // Horse emoji
                        .font(.system(size: 60))
                    
                    Text("Woah There")
                        .font(Font.custom("LondrinaSolid-Light", size: 32))
                        .foregroundColor(.white)
                    
                    Text("This next part is for grown-ups only.")
                        .font(Font.custom("LondrinaSolid-Light", size: 24))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("What is \(firstNumber) + \(secondNumber)?")
                        .font(Font.custom("LondrinaSolid-Light", size: 24))
                        .foregroundColor(.white)
                    
                    TextField("Your answer", text: $userAnswer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 200)
                        .focused($isTextFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isTextFieldFocused = false
                                }
                            }
                        }
                    
                    Button(action: {
                        isTextFieldFocused = false
                        checkAnswer()
                    }) {
                        Text("Submit")
                            .font(Font.custom("LondrinaSolid-Light", size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 50)
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func checkAnswer() {
        let correctAnswer = firstNumber + secondNumber
        let isCorrect = userAnswer == String(correctAnswer)
        completion(isCorrect)
        if !isCorrect {
            userAnswer = ""
            // Generate new numbers if answer was incorrect
            firstNumber = Int.random(in: 3...12)
            secondNumber = Int.random(in: 3...12)
        }
    }
} 
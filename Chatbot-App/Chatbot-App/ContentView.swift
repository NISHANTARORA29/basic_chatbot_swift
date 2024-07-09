//
//  ContentView.swift
//  Chatbot-App
//
//  Created by Nishant Arora on 09/07/24.
//

import SwiftUI

struct Message: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ContentView: View {
    @State private var messages: [Message] = []
    @State private var currentMessage: String = ""
    @State private var isBotTyping: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(message.content)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        Text(message.timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.trailing)
                                } else {
                                    VStack(alignment: .leading) {
                                        Text(message.content)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(10)
                                        Text(message.timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading)
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }
                    }
                    .onChange(of: messages) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                if isBotTyping {
                    HStack {
                        Text("Chatbot is typing...")
                            .italic()
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                HStack {
                    TextField("Enter message...", text: $currentMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: sendMessage) {
                        Text("Send")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Chatbot")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: clearChat()) {
                        Text("Clear Chat")
                    }
                }
                ToolbarItem(placement: .status) {
                    Button(action: { isDarkMode.toggle() }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    func sendMessage() {
        guard !currentMessage.isEmpty else { return }
        let userMessage = Message(content: currentMessage, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        currentMessage = ""
        isBotTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let botResponse = getBotResponse(for: userMessage.content)
            messages.append(botResponse)
            isBotTyping = false
        }
    }
    
    func clearChat() {
        messages.removeAll()
    }
    
    func getBotResponse(for message: String) -> Message {
        let response: String
        switch message.lowercased() {
        case "hi", "hello":
            response = "Hello! How can I assist you today?"
        case "how are you?":
            response = "I'm just a bot, but I'm here to help you!"
        case "what's your name?":
            response = "I am your friendly chatbot."
        case "what is swiftui?":
            response = "SwiftUI is a user interface toolkit that lets us design apps in a declarative way."
        default:
            response = "Sorry, I don't understand that. Can you ask something else?"
        }
        return Message(content: response, isUser: false, timestamp: Date())
    }
}

#Preview {
    ContentView()
}


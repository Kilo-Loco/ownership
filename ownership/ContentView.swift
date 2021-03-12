//
//  ContentView.swift
//  ownership
//
//  Created by Kilo Loco on 3/12/21.
//

import Amplify
import Combine
import SwiftUI

struct ContentView: View {
    
    let username = "amazon"
    let password = "password"
    
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                // Just keep changing the functions called here
                getSession(completion: query)
            }
    }
    
    func getSession(completion: @escaping () -> Void) {
        Amplify.Auth.fetchAuthSession { result in
            if (try? result.get().isSignedIn) == true {
                print("Signed IN")
                completion()
            } else {
                print("Signed OUT")
                Amplify.DataStore.clear { _ in completion() }
            }
        }
    }
    
    func signUp() {
        let options = AuthSignUpRequest.Options(userAttributes: [.init(.email, value: "kyleez@amazon.com")])
        Amplify.Auth.signUp(username: username, password: password, options: options) { result in
            print(try? result.get().nextStep)
        }
    }
    
    func confirm() {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: "633245") { result in
            print(try? result.get().isSignupComplete)
        }
    }
    
    func login() {
        Amplify.Auth.signIn(username: username, password: password) { result in
            print(try? result.get().isSignedIn)
        }
    }
    
    func signOut() {
        _ = Amplify.Auth.signOut()
        _ = Amplify.DataStore.clear()
    }
    
    @State var tokens = Set<AnyCancellable>()
    func create() {
        let todos = [
            Todo(name: "\(username) - \(UUID().uuidString)"),
            Todo(name: "\(username) - \(UUID().uuidString)"),
            Todo(name: "\(username) - \(UUID().uuidString)"),
        ]
        
        Publishers.Sequence(sequence: todos)
            .flatMap { (todo) -> AnyPublisher<Todo, DataStoreError> in
                Amplify.DataStore.save(todo)
            }
            .collect()
            .sink { (completion) in
                print(completion)
            } receiveValue: { todos in
                print("todos saved: \(todos)")
            }
            .store(in: &tokens)
    }
    
    func query() {
        Amplify.DataStore.query(Todo.self) { result in
            print(try? result.get())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

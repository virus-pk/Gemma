// GemmaGUI.swift
import SwiftUI
import Combine

// MARK: - Engine
class GemmaEngine: ObservableObject {
    @Published var output: String = ""
    @Published var instruction: String = ""
    @Published var isGenerating: Bool = false
    private var cancellable: AnyCancellable?
    private let model = "gemma3:4b"
    private let endpoint = URL(string: "http://localhost:11434/api/generate")!
    
    func generate() {
        guard !instruction.isEmpty else { return }
        isGenerating = true
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": model, "prompt": instruction, "stream": true]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        cancellable = URLSession.shared.bytes(for: request)
            .map { $0.0 }
            .flatMap { AsyncThrowingStream<Data, Error> { continuation in
                Task {
                    for try await line in $0.lines {
                        continuation.yield(line.data(using: .utf8) ?? Data())
                    }
                    continuation.finish()
                }
            } }
            .compactMap { String(data: $0, encoding: .utf8) }
            .compactMap { line -> String? in
                guard let json = try? JSONSerialization.jsonObject(with: Data(line.utf8), options: []) as? [String: Any],
                      let resp = json["response"] as? String else { return nil }
                return resp
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.isGenerating = false
                self?.instruction = ""
            }, receiveValue: { [weak self] chunk in
                withAnimation(.easeIn(duration: 0.2)) {
                    self?.output += chunk
                }
            })
    }
}

// MARK: - UI
struct ContentView: View {
    @StateObject private var engine = GemmaEngine()
    @FocusState private var promptFocused: Bool
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Gemma 3 · 4B · LOCAL")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
            // Output area
            ScrollView {
                Text(engine.output)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.black.opacity(0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding()
            
            // Input area
            HStack {
                TextField("Ask Gemma...", text: $engine.instruction)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .focused($promptFocused)
                    .onSubmit { engine.generate() }
                
                if engine.isGenerating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.teal)
                } else {
                    Button(action: { engine.generate() }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.teal)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .frame(minWidth: 600, minHeight: 500)
        .background(Color.black.opacity(0.9))
        .onAppear { promptFocused = true }
    }
}

// MARK: - App Delegate (classic entry)
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false)
        window.center()
        window.title = "Gemma GUI"
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Main
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()

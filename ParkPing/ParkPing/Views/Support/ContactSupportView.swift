import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubject = "General"
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    private let subjects = [
        "General",
        "Feature Suggestion",
        "Bug Report",
        "Usage Question",
        "Performance Issue",
        "UI Improvement",
        "Other"
    ]

    private let feedbackBackendURL = "https://feedback-board.iocompile67692.workers.dev"
    private let appName = "ParkPing"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    subjectSection
                    nameSection
                    emailSection
                    messageSection
                    submitSection
                }
                .padding()
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Message Sent!", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Thank you for reaching out. We'll get back to you soon.")
            }
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subject")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(subjects, id: \.self) { subject in
                    Button {
                        selectedSubject = subject
                        Haptics.light()
                    } label: {
                        Text(subject)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(selectedSubject == subject ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(selectedSubject == subject ? Color.parkPrimary : Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select subject: \(subject)")
                }
            }

            if selectedSubject == "Other" {
                TextField("Enter custom subject", text: $customSubject)
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 4)
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.headline)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
                .accessibilityLabel("Enter your name")
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email")
                .font(.headline)
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("Enter your email address")
        }
    }

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Message")
                .font(.headline)
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                .accessibilityLabel("Enter your message")
        }
    }

    private var submitSection: some View {
        Button {
            Task {
                await submitFeedback()
            }
        } label: {
            Group {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Submit")
                        .font(.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(canSubmit ? Color.parkPrimary : Color.gray)
            .clipShape(Capsule())
        }
        .disabled(!canSubmit || isSubmitting)
        .padding(.top, 8)
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty &&
        (selectedSubject != "Other" || !customSubject.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    private var effectiveSubject: String {
        selectedSubject == "Other" ? customSubject : selectedSubject
    }

    private func submitFeedback() async {
        isSubmitting = true
        errorMessage = nil

        let requestBody: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces),
            "subject": effectiveSubject,
            "message": message.trimmingCharacters(in: .whitespaces),
            "app_name": appName
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            let url = URL(string: "\(feedbackBackendURL)/api/feedback")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                isSubmitting = false
                showSuccess = true
            } else {
                isSubmitting = false
                errorMessage = "Failed to send message. Please try again later."
            }
        } catch {
            isSubmitting = false
            errorMessage = "Network error. Please check your connection and try again."
        }
    }
}

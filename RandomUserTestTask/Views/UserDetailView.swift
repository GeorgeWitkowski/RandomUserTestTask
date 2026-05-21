//
//  UserDetailView.swift
//  RandomUserTestTask
//
//  Created by George on 21/05/2026.
//


import SwiftUI

struct UserDetailView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AsyncImage(url: URL(string: user.picture.large)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.top, 20)
                
                VStack(spacing: 8) {
                    Text(user.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(user.email)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    DetailRowView(icon: "person.fill", title: "Gender", value: user.gender.capitalized)
                    
                    Divider()
                    
                    DetailRowView(icon: "mappin.and.ellipse", title: "Location", value: user.location.fullAddress)
                    
                    Divider()
                    
                    DetailRowView(icon: "calendar", title: "Registered", value: formattedDate(user.registered.date))
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Formatters
    
    private func formattedDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .none
            return displayFormatter.string(from: date)
        }
        
        return String(dateString.prefix(10))
    }
}

struct DetailRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
                .font(.system(size: 18))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}


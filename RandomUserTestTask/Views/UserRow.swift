//
//  UserRow.swift
//  RandomUserTestTask
//
//  Created by George on 20/05/2026.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: user.picture.thumbnail)) { image in
                image.resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.fullName)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(user.phone)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

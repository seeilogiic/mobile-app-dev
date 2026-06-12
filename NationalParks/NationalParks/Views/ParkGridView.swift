//
//  ParkGridView.swift
//  NationalParks
//
//  Created by Joshua Reed on 6/12/26.
//

import SwiftUI

struct ParkGridView: View {
    
    var stateCode : String
    @EnvironmentObject var parks : NationalParksViewModel
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            if parks.isLoading {
                ProgressView("Loading Parks...")
                    .padding()
            } else if parks.nationalParks.isEmpty {
                Text("No National Parks found in this state.")
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(parks.nationalParks) { park in
                        NavigationLink(destination: ParkDetailView(park: park)) {
                            VStack(alignment: .leading, spacing: 10) {
                                if let firstImage = park.images.first {
                                    AsyncImage(url: URL(string: firstImage.url)) { phase in
                                        switch phase {
                                        case .empty:
                                            ZStack {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(maxWidth: .infinity)
                                                    .aspectRatio(1.4, contentMode: .fill)
                                                ProgressView()
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.4, contentMode: .fill)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        case .failure:
                                            Color.gray
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.4, contentMode: .fill)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Color.gray
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1.4, contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                Text(park.fullName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                }
                .padding()
            }
        }
        .task {
            await parks.fetchNationalParks(stateCode: stateCode)
        }
        .alert(isPresented: $parks.hasError, error: parks.parkError) { _ in
            Button("Ok", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

#Preview {
    ParkGridView(stateCode: "CA")
        .environmentObject(NationalParksViewModel())
}
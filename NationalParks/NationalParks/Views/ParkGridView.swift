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
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        ScrollView {
            if parks.isLoading {
                ProgressView("Parks Loading...")
                    .padding()
                    
            }
            if parks.nationalParks.isEmpty {
                Text("No parks found for \(stateCode).")
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(parks.nationalParks) { park in
                        VStack(alignment: .leading, spacing: 10) {
                            
                            if let firstImage = park.images.first {
                                AsyncImage(url: URL(string: firstImage.url)) { phase in
                                    switch phase {
                                    case.empty:
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(maxWidth: .infinity)
                                                .aspectRatio(1.4, contentMode: .fill)
                                            
                                            ProgressView()
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(1.4, contentMode: .fill)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    case .failure:
                                        
                                        Color.gray
                                            .aspectRatio(1.4, contentMode: .fill)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Color.gray
                                    .aspectRatio(1.4, contentMode: .fill)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            Text(park.fullName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(.black))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .onAppear {
            parks.fetchNationalParks(stateCode: stateCode)
        }
    }
}

#Preview {
    ParkGridView(stateCode: "CA")
        .environmentObject(NationalParksViewModel())
}

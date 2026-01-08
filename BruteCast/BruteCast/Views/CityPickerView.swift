import SwiftUI

struct CityPickerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settingsVM: SettingsViewModel

    @StateObject private var searchVM = CitySearchViewModel()

    let slot: Int
    let onCitySelected: (City) -> Void

    var body: some View {
        NavigationView {
            ZStack {
                settingsVM.currentTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    searchField

                    Divider()
                        .background(settingsVM.currentTheme.text)

                    if searchVM.isSearching {
                        loadingView
                    } else if let error = searchVM.error {
                        errorView(error: error)
                    } else if searchVM.searchResults.isEmpty && !searchVM.searchText.isEmpty {
                        noResultsView
                    } else {
                        resultsList
                    }
                }
            }
            .navigationTitle("SEARCH CITY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("CANCEL") {
                        dismiss()
                    }
                    .font(.custom("JetBrainsMono-Regular", size: 12))
                    .foregroundColor(settingsVM.currentTheme.text)
                }
            }
        }
    }

    private var searchField: View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))

            TextField("", text: $searchVM.searchText, prompt: Text("Enter city name...")
                .font(.custom("JetBrainsMono-Regular", size: 14))
                .foregroundColor(settingsVM.currentTheme.text.opacity(0.5)))
                .font(.custom("JetBrainsMono-Regular", size: 14))
                .foregroundColor(settingsVM.currentTheme.text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)

            if !searchVM.searchText.isEmpty {
                Button(action: { searchVM.clear() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))
                }
            }
        }
        .padding(12)
        .background(settingsVM.currentTheme.background)
        .overlay(
            Rectangle()
                .stroke(settingsVM.currentTheme.text, lineWidth: 1)
        )
        .padding()
    }

    private var loadingView: View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: settingsVM.currentTheme.text))
            Text("SEARCHING...")
                .font(.custom("JetBrainsMono-Regular", size: 12))
                .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))
                .padding(.top, 8)
            Spacer()
        }
    }

    private func errorView(error: Error) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(settingsVM.currentTheme.accent)
            Text("ERROR")
                .font(.custom("JetBrainsMono-Bold", size: 14))
                .foregroundColor(settingsVM.currentTheme.text)
                .padding(.top, 8)
            Text(error.localizedDescription.uppercased())
                .font(.custom("JetBrainsMono-Regular", size: 10))
                .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }

    private var noResultsView: View {
        VStack {
            Spacer()
            Text("NO CITIES FOUND")
                .font(.custom("JetBrainsMono-Bold", size: 14))
                .foregroundColor(settingsVM.currentTheme.text.opacity(0.5))
            Spacer()
        }
    }

    private var resultsList: View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(searchVM.searchResults) { city in
                    cityRow(city)
                    Divider()
                        .background(settingsVM.currentTheme.text.opacity(0.3))
                }
            }
        }
    }

    private func cityRow(_ city: City) -> some View {
        Button(action: {
            onCitySelected(city)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name.uppercased())
                        .font(.custom("JetBrainsMono-Bold", size: 14))
                        .foregroundColor(settingsVM.currentTheme.text)

                    Text(city.fullDisplayName.uppercased())
                        .font(.custom("JetBrainsMono-Regular", size: 10))
                        .foregroundColor(settingsVM.currentTheme.text.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(settingsVM.currentTheme.text.opacity(0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(settingsVM.currentTheme.background)
        }
        .accessibilityLabel("Select \(city.fullDisplayName)")
    }
}

struct CityPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CityPickerView(slot: 0, onCitySelected: { _ in })
            .environmentObject(SettingsViewModel())
    }
}

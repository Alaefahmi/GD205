import SwiftUI

// MARK: - LoadingView (Skeleton Cards)
struct LoadingView: View {
    var cardCount: Int = 5

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<cardCount, id: \.self) { _ in
                    SkeletonJobCard()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - SkeletonJobCard
struct SkeletonJobCard: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row
            HStack(alignment: .top, spacing: 12) {
                SkeletonBox(width: 46, height: 46, cornerRadius: 10)

                VStack(alignment: .leading, spacing: 6) {
                    SkeletonBox(width: 120, height: 12, cornerRadius: 4)
                    SkeletonBox(width: 200, height: 16, cornerRadius: 4)
                }

                Spacer()

                SkeletonBox(width: 28, height: 28, cornerRadius: 8)
            }

            // Tags row
            HStack(spacing: 8) {
                SkeletonBox(width: 70, height: 24, cornerRadius: 6)
                SkeletonBox(width: 90, height: 24, cornerRadius: 6)
                SkeletonBox(width: 80, height: 24, cornerRadius: 6)
            }

            // Location & salary
            HStack {
                SkeletonBox(width: 150, height: 12, cornerRadius: 4)
                Spacer()
                SkeletonBox(width: 100, height: 12, cornerRadius: 4)
            }

            // Source & date
            HStack {
                SkeletonBox(width: 80, height: 20, cornerRadius: 6)
                Spacer()
                SkeletonBox(width: 60, height: 10, cornerRadius: 4)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .shimmer(isAnimating: isAnimating)
        .onAppear { withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { isAnimating = true } }
    }
}

// MARK: - SkeletonBox
struct SkeletonBox: View {
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.systemGray5))
            .frame(width: width, height: height)
    }
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    let isAnimating: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    if isAnimating {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                Color.white.opacity(0.5),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.5)
                        .offset(x: isAnimating ? geo.size.width * 1.5 : -geo.size.width)
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: isAnimating)
                    }
                }
                .clipped()
            )
    }
}

extension View {
    func shimmer(isAnimating: Bool) -> some View {
        modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

// MARK: - InlineLoadingView
struct InlineLoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.accentColor)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - AILoadingView
struct AILoadingView: View {
    let message: String
    @State private var dotCount = 0
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 72, height: 72)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                    .symbolEffect(.pulse)
            }

            VStack(spacing: 6) {
                Text(message + String(repeating: ".", count: dotCount + 1))
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Our AI is crafting the perfect response for you")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 3
        }
    }
}

#Preview {
    VStack {
        LoadingView(cardCount: 3)
    }
}

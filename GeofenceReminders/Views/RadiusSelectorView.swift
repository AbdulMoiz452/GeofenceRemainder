import SwiftUI

struct RadiusSelectorView: View {
    @Binding var radius: Double
    let minRadius: Double = 100
    let maxRadius: Double = 1000
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: CGFloat((radius - minRadius) / (maxRadius - minRadius)))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                    .offset(y: -geometry.size.width / 2 + 10)
                    .rotationEffect(.degrees((radius - minRadius) / (maxRadius - minRadius) * 360))
                
                Text("\(Int(radius))m")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let angle = atan2(value.location.y - geometry.size.width / 2, value.location.x - geometry.size.width / 2)
                        let normalizedAngle = (angle + .pi) / (2 * .pi)
                        radius = minRadius + normalizedAngle * (maxRadius - minRadius)
                        radius = max(minRadius, min(maxRadius, radius))
                    }
            )
        }
        .padding()
    }
}

struct RadiusSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        RadiusSelectorView(radius: .constant(500))
            .frame(width: 200, height: 200)
    }
}

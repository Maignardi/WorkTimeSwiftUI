import SwiftUI
import Combine

class TimerManager: ObservableObject {
    @Published var isTimerRunning = false
    @Published var remainingTime: TimeInterval = 0
    
    private var timer: Timer?
    private let workingHours: TimeInterval = 9.25 * 3600 // 9 hours and 15 minutes in seconds
    
    func startTimer(from startTime: Date) {
        isTimerRunning = true
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime)
        remainingTime = max(workingHours - elapsedTime, 0)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                timer.invalidate()
                self.isTimerRunning = false
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        isTimerRunning = false
    }
}

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var arrivalTime = Date()
    
    private var departureTime: Date {
        let calendar = Calendar.current
        let endTime = calendar.date(byAdding: .hour, value: 9, to: arrivalTime)!
        return calendar.date(byAdding: .minute, value: 15, to: endTime)!
    }
    
    private var formattedDepartureTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: departureTime)
    }
    
    private var formattedRemainingTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let remainingTime = TimeInterval(timerManager.remainingTime)
        return formatter.string(from: remainingTime) ?? ""
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Horário de Chegada")) {
                    DatePicker("", selection: $arrivalTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
                
                Section(header: Text("Horário de Saída")) {
                    Text(formattedDepartureTime)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Section(header: Text("Contagem Regressiva")) {
                    Text(formattedRemainingTime)
                        .font(.title)
                        .foregroundColor(.red)
                }
                
                Section {
                    Button(action: {
                        if timerManager.isTimerRunning {
                            timerManager.stopTimer()
                        } else {
                            timerManager.startTimer(from: arrivalTime)
                        }
                    }) {
                        Text(timerManager.isTimerRunning ? "Stop" : "Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(timerManager.isTimerRunning ? Color.red : Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitle("Marcação de Ponto")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

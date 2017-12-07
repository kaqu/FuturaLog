import Foundation

public final class CrashCatcher {

    public static func enable(inMode mode: Mode = .logging) {
        switch mode {
        case .logging:
            NSSetUncaughtExceptionHandler(exceptionLogHandler);
            signal(SIGABRT, signalLogHandler);
            signal(SIGILL, signalLogHandler);
            signal(SIGSEGV, signalLogHandler);
            signal(SIGFPE, signalLogHandler);
            signal(SIGBUS, signalLogHandler);
            signal(SIGPIPE, signalLogHandler);
        case .hiding:
            NSSetUncaughtExceptionHandler(exceptionVoidHandler);
            signal(SIGABRT, signalVoidHandler);
            signal(SIGILL, signalVoidHandler);
            signal(SIGSEGV, signalVoidHandler);
            signal(SIGFPE, signalVoidHandler);
            signal(SIGBUS, signalVoidHandler);
            signal(SIGPIPE, signalVoidHandler);
        }
    }
    
    public enum Mode {
        case logging
        case hiding
    }
}

fileprivate func exceptionLogHandler(_ exception: NSException)-> Swift.Void {
    Logger.send(Log(.crash, message: "Exception: \(exception)\n\n\(Thread.callStackSymbols.joined(separator: "\n"))\n"))
    Logger.flush()
}

fileprivate func signalLogHandler(_ signal: Int32)-> Swift.Void {
    Logger.send(Log(.crash, message: "Signal: \(signal)\n\n\(Thread.callStackSymbols.joined(separator: "\n"))\n"))
    Logger.flush()
    exit(signal)
}

fileprivate func exceptionVoidHandler(_ exception: NSException)-> Swift.Void { /* void */ }

fileprivate func signalVoidHandler(_ signal: Int32)-> Swift.Void { exit(signal) }

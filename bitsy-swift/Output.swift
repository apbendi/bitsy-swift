import Foundation

protocol CodeEmitter {
    func emit(code code: String);
    func finalize();
}

struct CmdLineEmitter: CodeEmitter {
    func emit(code code: String) {
        print(code, terminator: "")
    }

    func finalize() {}
}

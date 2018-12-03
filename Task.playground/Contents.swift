//import NonEmpty
import Task

Task.of(1).fork({ _ in }, { print($0) })



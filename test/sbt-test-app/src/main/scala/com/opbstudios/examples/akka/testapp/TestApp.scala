package com.opbstudios.examples.akka.testapp

import akka.http.scaladsl.marshallers.xml.ScalaXmlSupport.defaultNodeSeqMarshaller
import akka.http.scaladsl.server.{ HttpApp, Route }

/**
 * Server will be started calling `TestApp.startServer("localhost", 8080)`
 * and it will be shutdown after pressing return.
 */
object TestApp extends HttpApp with App {

  def routes: Route =
    pathEndOrSingleSlash { // Listens to the top `/`
      complete("Hello from scala HttpApp application.\n")
    }

  // This will start the server until the return key is pressed
  startServer("0.0.0.0", 8080)
}

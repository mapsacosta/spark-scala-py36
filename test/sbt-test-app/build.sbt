lazy val akkaHttpVersion = "10.0.9"

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      scalaHome       := Some(file("/opt/scala")),
      scalaVersion    := "2.11.8",
      organization    := "com.opbstudios.examples.akka.testapp"
    )),
    name := "scala-test-app",
    version := "0.1",
    mainClass in assembly := Some("com.opbstudios.examples.akka.testapp.TestApp"),
    libraryDependencies ++= Seq(
      "com.typesafe.akka" %% "akka-http"         % akkaHttpVersion,
      "com.typesafe.akka" %% "akka-http-xml"     % akkaHttpVersion
    )
  )

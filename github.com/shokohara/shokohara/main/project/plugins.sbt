addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.4.2")
addSbtPlugin("com.typesafe.sbt" % "sbt-native-packager" % "1.8.0-RC14")
addSbtPlugin("com.eed3si9n" % "sbt-buildinfo" % "0.9.0")
addSbtPlugin("com.typesafe.sbt" % "sbt-git" % "1.0.0")
addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.4.0")
addSbtPlugin("com.github.cb372" % "sbt-explicit-dependencies" % "0.2.13")
addSbtPlugin("ch.epfl.scala" % "sbt-scalafix" % "0.9.21")
addSbtPlugin("io.spray" % "sbt-revolver" % "0.9.1")
addSbtPlugin("org.scala-js" % "sbt-scalajs" % "1.2.0")
addSbtPlugin("ch.epfl.scala" % "sbt-scalajs-bundler" % "0.18.0")
addSbtPlugin("ch.epfl.lamp" % "sbt-dotty" % "0.4.4")
val grpcWebVersion = "0.3.0"

addSbtPlugin("org.portable-scala" % "sbt-scalajs-crossproject" % "1.0.0")

resolvers += "Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots"

addSbtPlugin("com.thesamet" % "sbt-protoc" % "0.99.31")

libraryDependencies += "com.thesamet.scalapb" %% "compilerplugin" % "0.10.2"

libraryDependencies += "com.thesamet.scalapb.grpcweb" %% "scalapb-grpcweb-code-gen" % grpcWebVersion

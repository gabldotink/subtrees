Global / onChangedBuildSource := ReloadOnSourceChanges
ThisBuild / organization := "com.github.shokohara"
ThisBuild / organizationName := "Sho Kohara"
//ThisBuild / scalafixDependencies += "com.github.liancheng" %% "organize-imports" % "0.4.3"
ThisBuild / sources in (Compile, doc) := Seq.empty
ThisBuild / publishArtifact in (Compile, packageDoc) := false
ThisBuild / scalaVersion := "2.13.4"
val circeVersion = "0.13.0"
val refinedVersion = "0.9.17"
val doobieVersion = "0.9.2"
val tapirVersion = "0.16.16"
val awsVersion = "2.15.20"
val zioConfigVersion = "1.0.0-RC29"
val poiVersion = "4.1.2"
val cormorantVersion = "0.3.0"

val lolProtos = crossProject(JSPlatform, JVMPlatform)
  .crossType(CrossType.Pure)
  .in(file("modules/leagueoflegends/protos"))
  .settings(
//    semanticdbEnabled := true,
//    semanticdbVersion := scalafixSemanticdb.revision,
    scalacOptions ++= Seq(
      "-deprecation",
      "-Wunused"
    ),
    PB.protoSources in Compile := Seq(
      (baseDirectory in ThisBuild).value / "protos" / "src" / "main" / "protobuf"
    ),
    libraryDependencies += "com.thesamet.scalapb" %%% "scalapb-runtime" % scalapb.compiler.Version.scalapbVersion
  )
  .jvmSettings(
    libraryDependencies += "com.thesamet.scalapb" %% "scalapb-runtime-grpc" % scalapb.compiler.Version.scalapbVersion,
    PB.targets in Compile := Seq(
      scalapb.gen() -> (sourceManaged in Compile).value
    )
  )
  .jsSettings(
    // publish locally and update the version for test
    libraryDependencies += "com.thesamet.scalapb.grpcweb" %%% "scalapb-grpcweb" % scalapb.grpcweb.BuildInfo.version,
    PB.targets in Compile := Seq(
      scalapb.gen(grpc = false) -> (sourceManaged in Compile).value,
      scalapb.grpcweb.GrpcWebCodeGenerator -> (sourceManaged in Compile).value
    )
  )

val lolApi = (project in file("modules/leagueoflegends/api"))
  .dependsOn(lolProtos.jvm)
  .settings(
    Compile / run / fork := true,
//    semanticdbEnabled := true,
//    semanticdbVersion := scalafixSemanticdb.revision,
    scalacOptions ++= Seq(
      "-deprecation",
      "-feature",
      "-language:higherKinds",
      "-Wunused",
      s"-Wconf:src=${target.value}/.*:s"
    ),
    scalacOptions in (Compile, console) --= Seq("-Ywarn-unused:imports", "-Xfatal-warnings"),
    addCompilerPlugin("org.typelevel" %% "kind-projector" % "0.11.1" cross CrossVersion.full),
    libraryDependencies ++= Seq(
      "com.merakianalytics.orianna" % "orianna" % "4.0.0-rc7",
      "org.slf4j" % "slf4j-api" % "1.7.30",
      "ch.qos.logback" % "logback-classic" % "1.2.3",
      "org.typelevel" %% "cats-core" % "2.3.0-M1",
      "dev.zio" %% "zio" % "1.0.3",
      "com.lihaoyi" %% "sourcecode" % "0.2.1",
      "eu.timepit" %% "refined" % refinedVersion,
      "org.scalameta" %% "munit" % "0.7.15" % Test,
      "com.github.bigwheel" %% "util-backports" % "2.1",
      "com.softwaremill.sttp.client" %% "core" % "2.2.9",
      "com.softwaremill.sttp.tapir" %% "tapir-sttp-client" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-openapi-docs" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-openapi-circe-yaml" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-redoc-http4s" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-enumeratum" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-refined" % tapirVersion,
      "io.chrisdavenport" %% "fuuid" % "0.4.0",
      "io.scalaland" %% "chimney" % "0.6.1",
      "org.typelevel" %% "cats-core" % "2.3.0-M1",
      "com.beachape" %% "enumeratum-circe" % "1.6.1",
      "com.beachape" %% "enumeratum-doobie" % "1.6.0",
      "com.pauldijou" %% "jwt-circe" % "4.3.0",
      "com.softwaremill.sttp.tapir" %% "tapir-zio" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-zio-http4s-server" % tapirVersion,
      "com.softwaremill.sttp.tapir" %% "tapir-json-circe" % tapirVersion,
      "dev.zio" %% "zio-interop-cats" % "2.2.0.1",
      "org.typelevel" %% "munit-cats-effect" % "0.4-fcb4c45",
      "org.tpolecat" %% "doobie-core" % doobieVersion,
      "org.tpolecat" %% "doobie-hikari" % doobieVersion,
      "org.tpolecat" %% "doobie-postgres" % doobieVersion,
      "org.tpolecat" %% "doobie-refined" % doobieVersion,
      "com.typesafe.scala-logging" %% "scala-logging" % "3.9.2",
      "eu.timepit" %% "refined" % refinedVersion,
      "eu.timepit" %% "refined-pureconfig" % refinedVersion,
      "com.softwaremill.macwire" %% "macros" % "2.3.7" % Provided,
      "io.circe" %% "circe-core" % circeVersion,
      "io.circe" %% "circe-generic" % circeVersion,
      "io.circe" %% "circe-refined" % circeVersion,
      "io.chrisdavenport" %% "cormorant-core" % cormorantVersion,
      "io.chrisdavenport" %% "cormorant-generic" % cormorantVersion,
      "io.chrisdavenport" %% "cormorant-parser" % cormorantVersion,
      "com.github.pureconfig" %% "pureconfig" % "0.14.0",
      "com.github.pureconfig" %% "pureconfig-generic" % "0.14.0",
      "com.github.pathikrit" %% "better-files" % "3.9.1"
    ),
    unusedCompileDependenciesFilter := moduleFilter(),
    buildInfoObject := "ThisBuildInfo",
    buildInfoKeys := Seq[BuildInfoKey](
      "packageName" -> packageName.value,
      "gitHeadCommit" -> git.gitHeadCommit.value.getOrElse(""),
      "gitHeadCommitDate" -> git.gitHeadCommitDate.value.getOrElse(""),
      "gitHeadMessage" -> git.gitHeadMessage.value.getOrElse(""),
      "gitBranch" -> git.gitCurrentBranch.value
    ),
    buildInfoOptions += BuildInfoOption.ToMap,
    buildInfoOptions += BuildInfoOption.ToJson,
    addCommandAlias("prePR", "; test; scalafmtCheckAll; test:unusedCompileDependenciesTest"),
    dockerExposedPorts := Seq(8080),
    testFrameworks += new TestFramework("munit.Framework")
  ).enablePlugins(BuildInfoPlugin, GitVersioning, JavaServerAppPackaging, GraalVMNativeImagePlugin, DockerPlugin)

val v = new {
  val scalaJSDom = "0.9.8"
  val scalaJSReact = "1.7.6"
  val scalaCss = "0.6.1"
  val reactJS = "16.13.1"
}

val lolClient = (project in file("modules/leagueoflegends/client"))
  .settings(
//    semanticdbEnabled := true,
//    semanticdbVersion := scalafixSemanticdb.revision,
    scalacOptions ++= Seq(
      "-deprecation",
      "-Wunused"
    ),
    npmDependencies in Compile ++= Seq("react" -> v.reactJS, "react-dom" -> v.reactJS),
    libraryDependencies ++= Seq(
      "org.scala-js" %%% "scalajs-dom" % v.scalaJSDom,
      "com.github.japgolly.scalajs-react" %%% "core" % v.scalaJSReact,
      "com.github.japgolly.scalajs-react" %%% "extra" % v.scalaJSReact,
      "com.github.japgolly.scalacss" %%% "core" % v.scalaCss,
      "com.github.japgolly.scalacss" %%% "ext-react" % v.scalaCss
    ),
    npmDependencies in Compile += "react-proxy" -> "1.1.8",
    npmDevDependencies in Compile += "file-loader" -> "6.0.0",
    npmDevDependencies in Compile += "style-loader" -> "1.2.1",
    npmDevDependencies in Compile += "css-loader" -> "3.5.3",
    npmDevDependencies in Compile += "html-webpack-plugin" -> "4.3.0",
    npmDevDependencies in Compile += "copy-webpack-plugin" -> "5.1.1",
    npmDevDependencies in Compile += "webpack-merge" -> "4.2.2",
    version in webpack := "4.43.0",
    version in startWebpackDevServer := "3.11.0",
    webpackResources := baseDirectory.value / "webpack" * "*",
    webpackConfigFile in fastOptJS := Some(baseDirectory.value / "webpack" / "webpack-fastopt.config.js"),
    webpackConfigFile in fullOptJS := Some(baseDirectory.value / "webpack" / "webpack-opt.config.js"),
    webpackConfigFile in Test := Some(baseDirectory.value / "webpack" / "webpack-core.config.js"),
    webpackDevServerExtraArgs in fastOptJS := Seq("--inline", "--hot"),
    webpackBundlingMode in fastOptJS := BundlingMode.LibraryOnly(),
    requireJsDomEnv in Test := true,
    addCommandAlias("dev", ";fastOptJS::startWebpackDevServer;~fastOptJS"),
    addCommandAlias("build", "fullOptJS::webpack")
  ).enablePlugins(ScalaJSBundlerPlugin).dependsOn(lolProtos.js)

val lolWindows = (project in file("modules/leagueoflegends/windows"))
  .settings(
    name := "windows",
//    semanticdbEnabled := true,
//    semanticdbVersion := scalafixSemanticdb.revision,
    scalacOptions ++= Seq(
      "-deprecation",
      "-Wunused"
    ),
    npmDependencies in Compile += "react" -> "16.8.6",
    npmDependencies in Compile += "react-dom" -> "16.8.6",
    npmDependencies in Compile += "react-proxy" -> "1.1.8",
    npmDevDependencies in Compile += "file-loader" -> "6.0.0",
    npmDevDependencies in Compile += "style-loader" -> "1.1.3",
    npmDevDependencies in Compile += "css-loader" -> "3.5.2",
    npmDevDependencies in Compile += "html-webpack-plugin" -> "4.2.0",
    npmDevDependencies in Compile += "copy-webpack-plugin" -> "5.1.1",
    npmDevDependencies in Compile += "webpack-merge" -> "4.2.2",
    libraryDependencies += "me.shadaj" %%% "slinky-web" % "0.6.5",
    libraryDependencies += "me.shadaj" %%% "slinky-hot" % "0.6.5",
    libraryDependencies += "org.scalatest" %% "scalatest" % "3.1.1" % Test,
    scalacOptions += "-Ymacro-annotations",
    version in webpack := "4.42.1",
    version in startWebpackDevServer := "3.10.3",
    webpackResources := baseDirectory.value / "webpack" * "*",
    webpackConfigFile in fastOptJS := Some(baseDirectory.value / "webpack" / "webpack-fastopt.config.js"),
    webpackConfigFile in fullOptJS := Some(baseDirectory.value / "webpack" / "webpack-opt.config.js"),
    webpackConfigFile in Test := Some(baseDirectory.value / "webpack" / "webpack-core.config.js"),
    webpackDevServerExtraArgs in fastOptJS := Seq("--inline", "--hot"),
    webpackBundlingMode in fastOptJS := BundlingMode.LibraryOnly(),
    requireJsDomEnv in Test := true,
    addCommandAlias("dev", ";fastOptJS::startWebpackDevServer;~fastOptJS"),
    addCommandAlias("build", "fullOptJS::webpack")
  ).enablePlugins(ScalaJSBundlerPlugin)

val zshMergeScala3 = (project in file("modules/zsh/mergeScala3"))
  .settings(
    scalaVersion := "3.0.0-M1",
//    semanticdbEnabled := true,
//    semanticdbVersion := scalafixSemanticdb.revision,
    scalacOptions ++= Seq(
      "-deprecation",
      "-Wunused"
    )
//    libraryDependencies ++= Seq("org.typelevel" %% "cats-core" % "2.3.0-M2")
  )

val zshMerge = (project in file("modules/zsh/merge"))
  .settings(
//    semanticdbEnabled := true,
//    semanticdbVersion := scalafixSemanticdb.revision,
    scalacOptions ++= Seq(
      "-deprecation",
      "-Wunused",
      "-Ytasty-reader"
    ),
    libraryDependencies ++= Seq(
      "com.github.pathikrit" %% "better-files" % "3.9.1",
//      "org.typelevel" %% "cats-core" % "2.3.0-M2",
      "eu.timepit" %% "refined" % "0.9.18",
      "com.monovore" %% "decline" % "1.3.0",
      "co.fs2" %% "fs2-io" % "2.4.6",
      "org.scalameta" %% "munit" % "0.7.15" % Test
    ),
    testFrameworks += new TestFramework("munit.Framework")
  )

val root = (project in file(".")).aggregate(lolApi, lolClient, lolWindows, lolProtos.jvm, lolProtos.js, zshMerge)
addCommandAlias(
  "ci",
  ";test:compile"
)

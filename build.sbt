val Http4sVersion = "0.23.30"
val CirceVersion = "0.14.10"
val MunitVersion = "1.1.0"
val LogbackVersion = "1.5.16"
val MunitCatsEffectVersion = "2.0.0"

lazy val root = (project in file("."))
  .settings(
    organization := "io.moleike",
    name := "hello-nix-scala",
    version := "0.0.1-SNAPSHOT",
    scalaVersion := "3.3.3",
    libraryDependencies ++= Seq(
      "org.http4s"      %% "http4s-ember-server" % Http4sVersion,
      "org.http4s"      %% "http4s-ember-client" % Http4sVersion,
      "org.http4s"      %% "http4s-circe"        % Http4sVersion,
      "org.http4s"      %% "http4s-dsl"          % Http4sVersion,
      "org.scalameta"   %% "munit"               % MunitVersion           % Test,
      "org.typelevel"   %% "munit-cats-effect"   % MunitCatsEffectVersion % Test,
      "ch.qos.logback"  %  "logback-classic"     % LogbackVersion
    ),
    assembly / assemblyJarName := "hello-nix-scala.jar",
    assembly / assemblyMergeStrategy := {
      case "module-info.class" => MergeStrategy.discard
      case x => (assembly / assemblyMergeStrategy).value.apply(x)
    }
  )

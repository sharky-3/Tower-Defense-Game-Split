<div id="top" class="">

<div align="center" class="text-center">
<h1>Split</h1>
<p><em>Hex-based 3D tower defense prototype built with Godot</em></p>

<img alt="last-commit" src="https://img.shields.io/github/last-commit/YOUR_USERNAME/split?style=flat&amp;logo=git&amp;logoColor=white&amp;color=0080ff" class="inline-block mx-1" style="margin: 0px 2px;">
<img alt="repo-top-language" src="https://img.shields.io/github/languages/top/YOUR_USERNAME/split?style=flat&amp;color=0080ff" class="inline-block mx-1" style="margin: 0px 2px;">
<img alt="repo-language-count" src="https://img.shields.io/github/languages/count/YOUR_USERNAME/split?style=flat&amp;color=0080ff" class="inline-block mx-1" style="margin: 0px 2px;">
<p><em>Built with the tools and technologies:</em></p>
<img alt="Godot" src="https://img.shields.io/badge/Godot%204-478CBF.svg?style=flat&amp;logo=godotengine&amp;logoColor=white" class="inline-block mx-1" style="margin: 0px 2px;">
<img alt="GDScript" src="https://img.shields.io/badge/GDScript-3582F7.svg?style=flat&amp;logo=godotengine&amp;logoColor=white" class="inline-block mx-1" style="margin: 0px 2px;">
</div>
<br>
<hr>
<h2>Table of Contents</h2>
<ul class="list-disc pl-4 my-0">
<li class="my-0"><a href="#overview">Overview</a></li>
<li class="my-0"><a href="#getting-started">Getting Started</a>
<ul class="list-disc pl-4 my-0">
<li class="my-0"><a href="#prerequisites">Prerequisites</a></li>
<li class="my-0"><a href="#installation">Installation</a></li>
<li class="my-0"><a href="#usage">Usage</a></li>
</ul>
</li>
</ul>
<hr>
<h2 id="overview">Overview</h2>
<p><strong>Split</strong> is a 3D hex-based tower defense prototype built in Godot 4. It focuses on designing, observing, and iterating on level layouts from a smooth, dynamic camera, while experimenting with enemy paths, tower placement, and environmental mood.</p>
<p><strong>Core ideas</strong></p>
<p>This project explores a clean workflow for building and testing tower defense mechanics on a hex grid. Key elements include:</p>
<ul class="list-disc pl-4 my-0">
<li class="my-0">🗺️ <strong>Hex Grid Map System:</strong> A procedural hex grid that can be regenerated and scaled on the fly for rapid level design.</li>
<li class="my-0">🎯 <strong>Tower Placement:</strong> A dedicated placing system for snapping towers onto valid tiles and giving immediate feedback through visual indicators.</li>
<li class="my-0">👾 <strong>Enemy Units:</strong> 3D enemies (goblins, skeletons, etc.) that can be spawned and directed across the map to test tower behavior.</li>
<li class="my-0">🎥 <strong>Cinematic Camera:</strong> A smooth, mouse-driven camera with a toggleable <em>spectate</em> mode for overview shots of the entire battlefield.</li>
<li class="my-0">✨ <strong>Visual Effects &amp; Atmosphere:</strong> Explosion effects, environmental lighting, and ambient audio to support the game feel.</li>
</ul>
<hr>
<h2 id="getting-started">Getting Started</h2>
<h3 id="prerequisites">Prerequisites</h3>
<p>This project requires the following:</p>
<ul class="list-disc pl-4 my-0">
<li class="my-0"><strong>Game Engine:</strong> <a href="https://godotengine.org/">Godot 4.5</a> (or compatible 4.x version)</li>
<li class="my-0"><strong>Platform:</strong> Windows, macOS, or Linux capable of running Godot 4 in 3D</li>
</ul>
<h3 id="installation">Installation</h3>
<p>Build and run <strong>Split</strong> from source using the Godot editor:</p>
<ol>
<li class="my-0">
<p><strong>Clone the repository:</strong></p>
<pre><code class="language-sh">❯ git clone https://github.com/YOUR_USERNAME/split
</code></pre>
</li>
<li class="my-0">
<p><strong>Navigate to the project directory:</strong></p>
<pre><code class="language-sh">❯ cd split
</code></pre>
</li>
<li class="my-0">
<p><strong>Open the project in Godot:</strong></p>
<pre><code class="language-sh">❯ godot4 --editor project.godot
</code></pre>
</li>
</ol>
<h3 id="usage">Usage</h3>
<p>You can run the project in two main ways:</p>
<ul class="list-disc pl-4 my-0">
<li class="my-0"><strong>From the Godot Editor:</strong> Open the project, select the main scene (e.g. <code>Map/main.tscn</code> or your chosen start scene), and press the <strong>Play</strong> button.</li>
<li class="my-0"><strong>From the command line:</strong></li>
</ul>
<pre><code class="language-sh">❯ godot4 --path . --main-pack project.godot
</code></pre>
<p>While in-game, you can:</p>
<ul class="list-disc pl-4 my-0">
<li class="my-0"><strong>Move/rotate the camera:</strong> Use the configured keyboard and mouse inputs (e.g. <code>WASD</code>, rotate and zoom bindings defined in <code>project.godot</code>).</li>
<li class="my-0"><strong>Toggle map spectate mode:</strong> Use the in-game UI button to smoothly transition the camera between normal and overview poses.</li>
<li class="my-0"><strong>Adjust hex grid scale:</strong> Use the UI slider to regenerate the hex map with a different scale for quick layout experiments.</li>
</ul>


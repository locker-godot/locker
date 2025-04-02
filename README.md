
<h1 class="text-center" align="center">
  <img alt="Locker - Storage Manager Plugin" src="https://raw.githubusercontent.com/locker-godot/locker/1c24488309e97408c274ac4db14c8b84cf633eeb/assets/images/banner.svg">
</h1>

<p align="center">Easily save, load, version and manage your Godot game's data!</p>

<p class="text-center" align="center">
  <a href="https://godotengine.org/download/" target="_blank">
    <img alt="Godot v4.3+" src="https://img.shields.io/badge/Godot_v4.3+-%23478cbf?color=478cbf&logo=godotengine&logoColor=ffedf5&style=for-the-badge" />
  </a>
  <a href="LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/locker-godot/locker?labelColor=fdf2ed&color=4F5D75&style=for-the-badge">
  </a>
  <a href="https://github.com/locker-godot/locker/releases">
    <img alt="Latest Release" src="https://img.shields.io/github/v/release/locker-godot/locker?labelColor=fdf2ed&color=2D3142&style=for-the-badge">
  </a>
  <a href="https://ko-fi.com/nadjiel" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Ko--fi-ffda6e?logo=kofi&color=ffda6e&style=for-the-badge" >
  </a>
</p>

<h2>🤔 About</h2>
<p>The Locker plugin is a framework created in <b>Godot 4.3</b> meant to simplify the process of <b>saving, loading and managing data</b> in Godot projects.</p>
<p>This plugin has as one of its main goals being open for user <b>customizations</b>, allowing the use of different <b>user defined strategies</b> for <b>accessing data</b>.</p>

<h2>✨ Features</h2>
Down below are listed the main features of this Plugin.

<h3>📪 Gathering and Distribution of data</h3>
<p>The gathering and distribution of data is the main feature of this framework. This functionality refers to how this plugin is able to keep track of who needs access to the storage, and to handle how that access is realized.</p>
<p>For the implementation of this feature, two important concepts are used: <img alt="StorageManager icon" src="https://raw.githubusercontent.com/locker-godot/locker/1c24488309e97408c274ac4db14c8b84cf633eeb/addons/locker/icons/accessor_group.svg" style="height: 1em" />
<code>StorageManagers</code> and <img alt="StorageManager icon" src="https://raw.githubusercontent.com/locker-godot/locker/1c24488309e97408c274ac4db14c8b84cf633eeb/addons/locker/icons/storage_accessor.svg" style="height: 1em" /> <code>StorageAccessors</code>.
<code>StorageAccessors</code> are <code>Nodes</code> capable of handling the access of saved data, while <code>StorageManagers</code> are responsible for managing the <code>StorageAccessors</code> that need to access that data.</p>
<p>
  In order to be able to manipulate those <code>StorageAccessors</code>, an autoload called <code>GlobalStorageManager</code> is defined when the plugin is activated.
  This is a singleton capable of collecting and sending data to all active <code>StorageAccessors</code> in the scene.
</p>

<h3>🗃 Multiple Save Files</h3>
<p>One of the features that this Plugin provides is the possibility of using
<b>multiple</b> save files for storing <b>data</b>.
That can be used to achieve systems similar to some games where data
for <b>different gameplays</b> are stored in <b>different save files</b>,
usually referred to as <b>file 1</b>, <b>file 2</b>, <b>file 3</b>
and etc.</p>
<p>The multiple save files system also makes it possible to <b>store files</b>
with <b>whatever name</b> you'd like.
You can even use stringified timestamps to store
different save files at different times.</p>

<h3>🔪 Separation in Partitions</h3>
<p>Beyond allowing the separation of data in multiple save files, the Locker
Plugin also allows the <b>separation</b> of data inside a save file in <b>multiple</b> <b>partitions</b>.
This can be used to better <b>organize</b> the <b>data</b> or even to make the data
<b>accessing</b> process <b>quicker</b>, when only the data of a few partitions is involved.</p>
<p>Partitions can be used, for example, to separate data from different players
so that when the data of one player is needed, only its partition needs to
be loaded.</p>

<h3>⏰ Asynchronous operations</h3>
<p>Another feature that this Plugin brings is the handling of <b>file accessing</b> operations as <b>asynchronous</b> functions. This allows the game to keep being responsive even if there are large amounts of data to load or save.</p>
<p>For the user convenience, handy <b>signals</b> are provided when the data manipulation <b>initializes</b> or <b>finishes</b>, so that actions can be taken at those times.</p>
<p>To facilitate the interaction with those asynchronous operations, the methods involved were defined as <b>coroutines</b>, so that you can use the <code>await</code> keyword in order to await their execution only when necessary.</p>

<h3>📰 Save files versioning</h3>
<p>The Locker Plugin also aims at facilitating the process of <b>updating</b> old save files to new <b>versions</b> of a game.</p>
<p>
  That's why <code>StorageAccessors</code> are composed by <img alt="StorageManager icon" src="https://raw.githubusercontent.com/locker-godot/locker/1c24488309e97408c274ac4db14c8b84cf633eeb/addons/locker/icons/storage_accessor_version.svg" style="height: 1em" /> <code>StorageAccessorVersions</code>.
  These <code>StorageAccessorVersions</code> allow you to define <b>different mechanisms</b> to handle the data accessed across <b>different versions</b> of your save files, which can facilitate the process of <b>updating</b> the scheme of <b>saved data</b> in new game versions.
</p>

<h3>🔑 Customizable Access Strategies</h3>
<p>One of the main objectives of this plugin is being open to <b>customizations</b>. That's why the <img alt="StorageManager icon" src="https://raw.githubusercontent.com/locker-godot/locker/1c24488309e97408c274ac4db14c8b84cf633eeb/addons/locker/icons/access_strategy.svg" style="height: 1em" /> <code>AccessStrategy</code> concept is implemented.</p>
<p>The <code>AccessStrategy</code> is a class that <b>abstracts</b> how <b>data</b> is written and read using this Plugin. This approach allows for <b>new</b> <code>AccessStrategies</code> to be easily implemented in the future, or even <b>by users</b>.</p>
<p>For the default usage of this Plugin, two built-in <code>AccessStrategies</code> are available: The <code>JSONAccessStrategy</code> and the <code>EncryptedAccessStrategy</code>.</p>

<h3>🔧 Easy configuration</h3>
<p>
  With all these features, the Plugin needed a place to allow <b>quick configuration</b>.
  For that, the Godot built-in <code>ProjectSettings</code> are used. That means that for quickly setting up your preferred configurations for this Plugin, you just need to go to the path <code>"addons/locker"</code> in your <code>ProjectSettings</code> and tweak the desired properties.
</p>

<h2>🔽 Installation</h2>
<p>To download this Asset, you can use one of the following ways:</p>

<h3>Godot Asset Library</h3>
<em>Latest Stable Version</em>
<p>
The <a href="https://godotengine.org/asset-library/asset/3765" target="_blank">Asset Library</a> is the easiest way of downloading this project.
The version you will encounter there is the <b>latest stable</b> one.
</p>
<p>
When downloading through the Asset Library, you can easily select what <code>AccessStrategies</code> you want to include or exclude from your project.
That way, you don't have to download <code>AccessStrategies</code> that you aren't going to use.
</p>

<h3>Github Releases</h3>
<em>Latest Stable Version</em>
<p>
One of the ways of downloading this plugin is directly through <a href="https://github.com/locker-godot/locker/releases">Github Releases</a>.
There, you'll find the available <b>stable versions</b>.
Just select the desired version and install it.
</p>

<h3>Itch.io</h3>
<em>Latest Stable Version</em>
<p>
This project is also available on <a href="https://nadjiel.itch.io/locker" target="_blank">Itch.io</a>, if you prefer downloading from there.
The version available there is also the <b>latest stable</b> one.
</p>

<h3>Github Development</h3>
<em>Latest Unstable Version</em>
<p>
If you want to download the <b>latest unstable</b> version, you can download it cloning the <a href="https://github.com/locker-godot/locker">Github repository</a> or downloading it directly from there.
</p>

<hr>

<p>
<b>After installing this Plugin, make sure to activate it in the Godot settings, so that it can automatically add its autoload to the project and work properly.</b>
</p>

<h2>📚 Documentation & examples</h2>
<p>Documentation for this Asset can be found directly in the code, written with <b>GDScript Doc Comments</b>, so that you can read them in the <b>Godot Editor</b>.</p>
<p>Some starter examples of core functionalities of the Plugin can be found in the <a href="https://github.com/locker-godot/locker/tree/main/examples/"><code>examples</code></a> folder in the root of this project on Github.</p>
<p>Guides and tutorials about how to use this framework will be/ are also available in the <a href="https://github.com/locker-godot/locker/wiki">Github Wiki</a>.</p>

<h2>🧪 Testing</h2>
<p>
This project has <b>unit tests</b> (located in the <a href="https://github.com/locker-godot/locker/tree/main/test/unit/"><code>test/unit</code></a> folder) to validate its correct functionality.
Those tests are written with the use of the <a href="https://github.com/bitwes/Gut" target="_blank">GUT Plugin</a>, by <a href="https://github.com/bitwes" target="_blank">@bitwes</a>, also available in the <a href="https://godotengine.org/asset-library/asset/1709" target="_blank">Godot Asset Library</a>.</p>

<h2>🤝 Contributions</h2>
<p>If you like this project, consider supporting me on <a target="_blank" href="https://ko-fi.com/nadjiel">Ko-fi</a> or on <a target="_blank" href="https://github.com/sponsors/nadjiel">Github</a> so I can keep on making content like this! :D</p>
<p class="text-center" align="center">
  <a target="_blank" href="https://ko-fi.com/J3J71AXVC6">
    <img alt="Buy Me a Coffee at ko-fi.com" border="0" src="https://storage.ko-fi.com/cdn/kofi2.png?v=6" style="border:0px;height:2em;max-width:160px" height="2em">
  </a>
</p>
<p>If you can't support me those ways, starring on <a href="https://github.com/locker-godot/locker">Github</a> or rating, commenting or adding to collections on <a href="https://nadjiel.itch.io/locker" target="_blank">Itch.io</a> would go a long way :)</p>
<p>Other than that, here are some ways you can contribute to this project, so that we can improve it together:</p>
<ul>
<li>If you found a bug, feel free to <a target="_blank" href="https://github.com/locker-godot/locker/issues/new">Create an Issue</a> pointing it out. The more informations the better.
Also, including a Minimal Reproduction Project would go a long way;</li>
<li>If you see an <a target="_blank" href="https://github.com/locker-godot/locker/issues">Issue</a> that you think you can help with, give it a try! :)</li>
<li>If you have an idea for a feature, you can also create an <a target="_blank" href="https://github.com/locker-godot/locker/issues">Issue</a>.</li>
</ul>

<h2>📃 License</h2>
<p>
This framework is distributed under the <a href="https://github.com/locker-godot/locker/blob/main/LICENSE">MIT</a> license, you can use it on your projects.
Attribution is appreciated, but not necessary.
</p>
<p>If you use this project and you'd like to, let me know commenting on <a href="https://nadjiel.itch.io/locker" target="_blank">Itch.io</a>! I'd love to see what you can make with it :)</p>

<h2>Disclaimer</h2>
<p>
This project uses some icons adapted from third party libraries. Here's a list of those icons, together with their licenses:
</p>
<dl>
  <dt>Material Design Icons (Apache 2.0)</dt>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/access_executor.svg"><code>AccessExecutor</code> icon</a>, adapted from <a href="https://pictogrammers.com/library/mdi/icon/share/">"share"</a></dd>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/locker_plugin.svg"><code>LockerPlugin</code> icon</a>, adapted from <a href="https://pictogrammers.com/library/mdi/icon/locker-multiple/">"locker-multiple"</a></dd>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/accessor_group.svg"><code>AccessorGroup</code> icon</a>, adapted from <a href="https://pictogrammers.com/library/mdi/icon/content-save-edit/">"content-save-edit"</a></dd>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/storage_accessor.svg"><code>StorageAccessor</code> icon</a>, adapted from <a href="https://pictogrammers.com/library/mdi/icon/content-save-edit/">"content-save-edit"</a></dd>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/storage_accessor_version.svg"><code>StorageAccessorVersion</code> icon</a>, adapted from <a href="https://pictogrammers.com/library/mdi/icon/content-save-edit/">"content-save-edit"</a></dd>
  <dt>JAM Icons (MIT)</dt>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/access_operation.svg"><code>AccessOperation</code> icon</a>, adapted from "write-f"</dd>
  <dt>Bitcoin Icons (MIT)</dt>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/access_strategy.svg"><code>AccessStrategy</code> icon</a>, adapted from <a href="https://bitcoinicons.com/">"two keys"</a></dd>
  <dt>Phosphor Icons (MIT)</dt>
  <dd><a href="https://github.com/locker-godot/locker/blob/main/addons/locker/icons/util.svg"><code>Util</code> icon</a>, adapted from <a href="https://phosphoricons.com/?q=%22wrench%22">"wrench"</a></dd>
</dl>

<h2>Credits</h2>
<p>Framework created with ❤️ by <a href="https://github.com/nadjiel" target="_blank">@nadjiel</a></p>

<p>I hope this framework helps you with your project! :D</p>

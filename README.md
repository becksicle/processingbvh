# processingbvh
BVH parsing and rendering in <a href="https://processing.org">processing</a>.
<a href="https://research.cs.wisc.edu/graphics/Courses/cs-838-1999/Jeff/BVH.html">BVH</a> is an animation file 
format developed by Biovision that models joint relations and rotations hierarchically.

Put your BVH files in the data directory and run bvh to playback the rendered animations.

Camera navigation is done through <a href="http://mrfeinberg.com/peasycam/">PeasyCam</a>.
You will need to import the dependency.

Here are some basic controls to step through the animation:
<ul>
<li>"s" - pauses / unpauses</li>
<li>"l" - draw labels or not</li>
<li>"n" - goto next frame </li>
<li>"p" - goto previous frame </li>
<li>"d" - print joints to console</li>
<li>"j" - read next file</li>
<li>"f" - refresh file list</li>
</ul>

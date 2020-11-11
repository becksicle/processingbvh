# processingbvh
BVH parsing and rendering in processing.
<a href="https://research.cs.wisc.edu/graphics/Courses/cs-838-1999/Jeff/BVH.html">BVH</a> is an animation file 
format developed by Biovision that models joint relations and rotations hierarchically.

Put your BVH files in the data directory and run bvh to playback the rendered animations.

There are some very basic controls that help you navigate the scene:
<ul>
<li>"x" - rotate camera around y axis</li>
<li>"z" - advance camera in the z direction</li>
<li>"a" - move camera back in the z direction</li>
<li>"y" - translate in the y direction</li>
<li>"u" - translate in the negative y direction</li>
</ul>

And some basic controls to step through the animation:
<ul>
<li>"s" - pauses / unpauses</li>
<li>"l" - draw labels or not</li>
<li>"r" - reset camera position</li>
<li>"n" - goto next frame </li>
<li>"p" - goto previous frame </li>
<li>"d" - print joints to console</li>
<li>"j" - read next file</li>
<li>"f" - refresh file list</li>
</ul>

# Contribution Guidelines

>  :memo: By using this addon ("GodotVisualShader-Extras") and its different versions for the Godot Engine you can use the code in your projects under the given license. Furthermore, you have the option to contribute back changed you made back to this repository here. This contribution will come in the from of **P**ull **R**equests (short: **PR**s). By creating PRs you acknowledge that your changes will then also apply under the same MIT license as the already existing code.

> :memo: A general understanding of how Git and GitHub works is required to be able to contribute to this repository. For instance, keywords such as "squash", "merge", "rebase" should mean something to you.

## Process of a PR
1. You created changes to the forked repository (added new Visual Shader Nodes or fixed bugs)
2. You create a Pull Request according to the Pull Request template supplied. You add screenshots and/or videos of your added Visual Shader Nodes. In addition you will add examples of your added Nodes to the already existing ``examples2D`` and ``examples3D`` scenes. Also, idealistically you keep the number of added Nodes and bug fixes low for easier and quicker reviews.
3. Your Pull Request will get labeled and reviewed (this may take a while depending on the size of your Pull Request and my time availability)
4. If your changes are approved you will be asked to squash them to one commit. After that your PR will get merged. Otherwise, if there are requested changes, please apply those to your Pull Request.

## Example Scenes
### Example2D Scene
![Example2D Scene](https://user-images.githubusercontent.com/38077837/236550509-fb5d6616-dfdc-4149-aa6d-bf08de78cf2f.png)

This scene uses Control Nodes structured in several layers of Containers to supply a good example overview of a specific Visual Shader Nodes category. For instance there are categories such as "BlendModes" which are also present as subcategories inside the "Add Node" dialog in the Visual Shader Editor. Please note that all current resources used in this scene are the addon icon and the ``icon.svg`` which comes with every new Godot 4 project. New resources you want to use for examples should be compatible with the MIT license and be put inside the ``AddonExamples/Resources`` folder. Credits and their licenses will go into the ``Credits.md`` file. The resources itself should be kept to an absolute minimum (to minimize the size of the folder). Preferably you only use either the addon icon and/or the ``icon.svg``.

### Example3D Scene
![Example3D Scene](https://user-images.githubusercontent.com/38077837/236553189-fb1f4511-faff-4e23-a694-2652f06b3099.png)

This scene uses the ``CSGTestScene`` Scene. New Showcase Meshes are to be put in the center of this scene. The demo mesh should ideally be a sphere but you can use others as well. The use of ustom meshes should be kept to an absolute minimum. The demo scenes should be done as follows:
1. Parent 3D Node with the name of the Visual Shader Node
2. Child Mesh Instance Node showcasing the effect named "Test" + MESH_TYPE
3. Child Mesh Instance Node with TextMesh with the name of the Visual Shader Node. The size of the text should be adjusted to fit into the demo CSG scene (as shown in the picture above).


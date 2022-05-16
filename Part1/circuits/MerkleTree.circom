pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    
    var leafSize = 2**n; // case 3 levels = 8 leaves
    var numberOfNodes = 2**(n+1) - 1; // case 3 levels = 15 nodes
    component hashes[leafSize - 1];
    var tree[numberOfNodes];


    for (var i = 0; i < leafSize; i++) {
        tree[i] = leaves[i];
    }

    // hashes
    for (var i = 0; i < leafSize - 1; i++) {
        hashes[i] = Poseidon(2);
        hashes[i].inputs[0] <== tree[2 * i];
        hashes[i].inputs[1] <== tree[2 * i + 1];
        tree[leafSize + 1] = hashes[i].out;
    }

    // root
    root <== hashes[leafSize - 2].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component poseidon[n];
    signal items[n+1];

    items[0] <== leaf;

    for (var i = 0; i < n; i++) {
        poseidon[i] = Poseidon(2);

        // acheck if pathindex is equal to 0 or 1
        assert(path_index[i] == 0 || path_index[i] == 1);


        poseidon[i].inputs[0] <== (path_elements[i] - items[i]) * path_index[i] + items[i];
        poseidon[i].inputs[1] <== (items[i] - path_elements[i]) * path_index[i] + path_elements[i];
        
        items[i+1] <== poseidon[i].out;
    }
    // root
    root <== items[n];
}
import scipy.io
import numpy as np
import torch

# Load the MATLAB file
print("Loading MATLAB file...")
mat_data = scipy.io.loadmat('RF_data_for_NN_oneLoop.mat')

# Print available keys to understand the structure
print("\nAvailable keys in the .mat file:")
for key in mat_data.keys():
    if not key.startswith('__'):
        print(f"  {key}: shape = {mat_data[key].shape if hasattr(mat_data[key], 'shape') else 'N/A'}")

# Extract x (features) and t (labels)
x = mat_data['x']
t = mat_data['t']

print(f"\nExtracted data:")
print(f"  x (features) shape: {x.shape}")
print(f"  t (labels) shape: {t.shape}")
print(f"  x dtype: {x.dtype}")
print(f"  t dtype: {t.dtype}")
print(f"  t unique values: {np.unique(t)}")

# Convert to appropriate types for PyTorch
# Convert x to float32 (standard for neural networks)
x = x.astype(np.float32)

# Convert t to categorical labels (int64 for PyTorch)
# If t is already categorical, just convert to int64
# If t is one-hot encoded, convert to class indices
if len(t.shape) > 1 and t.shape[0] > 1:
    # One-hot encoded (shape: num_classes x num_samples), convert to class indices
    # Use axis=0 to find which class is active for each sample
    t = np.argmax(t, axis=0).astype(np.int64)
    print(f"\nConverted one-hot encoded labels to class indices")
else:
    # Already categorical or single column
    t = t.flatten().astype(np.int64)
    print(f"\nFlattened and converted labels to int64")

print(f"\nFinal data shapes:")
print(f"  x (features): {x.shape}, dtype: {x.dtype}")
print(f"  t (labels): {t.shape}, dtype: {t.dtype}")
print(f"  Number of classes: {len(np.unique(t))}")

# Save as PyTorch tensors
print("\nSaving data for PyTorch...")
torch.save({
    'features': torch.from_numpy(x),
    'labels': torch.from_numpy(t)
}, 'data_for_pytorch.pt')

print("Saved as 'data_for_pytorch.pt'")

# Also save as numpy arrays for alternative loading
np.savez('data_for_pytorch.npz', features=x, labels=t)
print("Also saved as 'data_for_pytorch.npz' (numpy format)")

print("\nTo load in PyTorch:")
print("  data = torch.load('data_for_pytorch.pt')")
print("  features = data['features']")
print("  labels = data['labels']")


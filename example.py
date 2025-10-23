#!/usr/bin/env python3
"""
AI Image Generator - Example Usage
Demonstrates how to use the API programmatically
"""

import requests
import time
import base64
from PIL import Image
from io import BytesIO

def generate_images(prompt, n_images=2, n_inf_steps=200):
    """
    Generate images using the API
    
    Args:
        prompt (str): Text description of the image
        n_images (int): Number of images to generate
        n_inf_steps (int): Quality level (50-500)
    
    Returns:
        list: Generated PIL Images
    """
    # Start generation job
    response = requests.post('http://localhost:5001/text_to_image', json={
        'prompt': prompt,
        'n_images': n_images,
        'n_inf_steps': n_inf_steps
    })
    
    if response.status_code != 200:
        raise Exception(f"API Error: {response.status_code}")
    
    job_id = response.json()['job_id']
    print(f"🎨 Started generation job: {job_id}")
    
    # Poll for completion
    while True:
        status_response = requests.get(f'http://localhost:5001/jobs/{job_id}/')
        status = status_response.json()
        
        if status.get('finished'):
            print("✅ Generation completed!")
            break
        
        if 'response' in status:
            progress = status['response'][0]['t']
            total = status['response'][0]['total_t']
            print(f"📊 Progress: {progress}/{total} ({progress/total*100:.1f}%)")
        
        time.sleep(2)
    
    # Convert base64 images to PIL Images
    images = []
    for item in status['response']:
        img_data = base64.b64decode(item['img'])
        img = Image.open(BytesIO(img_data))
        images.append(img)
    
    return images

def main():
    """Example usage"""
    print("🎨 AI Image Generator - Example Usage")
    print("=" * 40)
    
    # Example prompts
    prompts = [
        "a majestic dragon flying over a castle",
        "a serene mountain lake at sunset",
        "a futuristic city with flying cars"
    ]
    
    try:
        for i, prompt in enumerate(prompts, 1):
            print(f"\n🖼️  Generating image {i}/3: '{prompt}'")
            images = generate_images(prompt, n_images=1, n_inf_steps=100)
            
            # Save the first image
            if images:
                filename = f"example_{i}.png"
                images[0].save(filename)
                print(f"💾 Saved as: {filename}")
        
        print("\n🎉 All examples completed!")
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to API server")
        print("Please make sure the API server is running:")
        print("  python api.py")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()

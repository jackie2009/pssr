using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class PlanarSSR : MonoBehaviour
{
	public RenderTexture worldPosTex;
	public static int rtSize = 256;
	private Material matss;
	public ComputeShader computeShader;
	public bool dispatchIndirectMode = false;
    public float waterHeight;
	public RenderTexture reflectTex;
 	// Use this for init
    int kernelMain;
    private int kernelCSClear;
    private ComputeBuffer indirectArguments;
    private Camera camera;
	private void Start()
	{
		initRes();
		initComputeShader();
	}

	private void initRes()
	{
		  camera = GetComponent<Camera>();
		 matss=new Material(Shader.Find("Unlit/SSToWorldPos"));//如果发布程序 这里需要用resources 或assetbundle 加载
         worldPosTex = RenderTexture.GetTemporary(rtSize, rtSize, 16, RenderTextureFormat.ARGBFloat);
         reflectTex = new RenderTexture(rtSize, rtSize, 24,RenderTextureFormat.R8);
         reflectTex.enableRandomWrite = true;
         reflectTex.Create();
         Shader.SetGlobalTexture("WaterPssrTex", reflectTex);
	}

	private void initComputeShader()
	{
		print(SystemInfo.supportsComputeShaders);
		kernelMain =  computeShader.FindKernel("CSMain");
		kernelCSClear =  computeShader.FindKernel("CSClear");

		computeShader.SetTexture(kernelMain,"Result",reflectTex);
		computeShader.SetTexture(kernelCSClear,"Result",reflectTex);
		computeShader.SetTexture(kernelMain,"inputTexture", worldPosTex);
		 
		indirectArguments= new ComputeBuffer(1, sizeof(uint) * 3, ComputeBufferType.IndirectArguments);
		indirectArguments.SetData(new uint[]{(uint)(rtSize / 8), (uint)(rtSize / 8), 1});
	}

	private void Update()
	{
		updateCameraRay();
	    UpdateComputeShader();
        
    }

	private void updateCameraRay()
	{
		 
		Matrix4x4 frustumCorners = Matrix4x4.identity;
		float fovWHalf = camera.fieldOfView * 0.5f;
		Vector3 toRight = camera.transform.right * camera.nearClipPlane * Mathf.Tan(fovWHalf * Mathf.Deg2Rad) * camera.aspect;
		Vector3 toTop = camera.transform.up * camera.nearClipPlane * Mathf.Tan(fovWHalf * Mathf.Deg2Rad);
		Vector3 topLeft = (camera.transform.forward * camera.nearClipPlane - toRight + toTop);
		float camScale = topLeft.magnitude * camera.farClipPlane / camera.nearClipPlane;
		topLeft.Normalize();
		topLeft *= camScale;
		Vector3 topRight = (camera.transform.forward * camera.nearClipPlane + toRight + toTop);
		topRight.Normalize();
		topRight *= camScale;
		Vector3 bottomRight = (camera.transform.forward * camera.nearClipPlane + toRight - toTop);
		bottomRight.Normalize();
		bottomRight *= camScale;
		Vector3 bottomLeft = (camera.transform.forward * camera.nearClipPlane - toRight - toTop);
		bottomLeft.Normalize();
		bottomLeft *= camScale;
		frustumCorners.SetRow(2, topLeft);
		frustumCorners.SetRow(3, topRight);
		frustumCorners.SetRow(1, bottomRight);
		frustumCorners.SetRow(0, bottomLeft);
		matss.SetMatrix("frustumCorners", frustumCorners);
	}

	void UpdateComputeShader() {
        
		computeShader.SetVector("cmrPos",transform.position);
		if(dispatchIndirectMode==false)
        computeShader.Dispatch(kernelCSClear, rtSize / 8, rtSize / 8, 1);
		else
			computeShader.DispatchIndirect(kernelCSClear,indirectArguments);
        computeShader.SetFloat("WaterHeight", waterHeight);

        var m = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
      
        //高版本 可用  computeShader.SetMatrix("matrix_VP", m); 代替 下面数组传入
        float[] mlist = new float[] {
            m.m00,m.m10,m.m20,m.m30,
           m.m01,m.m11,m.m21,m.m31,
            m.m02,m.m12,m.m22,m.m32,
            m.m03,m.m13,m.m23,m.m33
        };
 
          
        computeShader.SetFloats("matrix_VP", mlist);

        if(dispatchIndirectMode==false)
		 computeShader.Dispatch(kernelMain,rtSize/8, rtSize / 8,1);
       else
		computeShader.DispatchIndirect(kernelMain,indirectArguments);

    }
	private void OnDestroy()
	{
		RenderTexture.ReleaseTemporary(worldPosTex);
		 
	}

	private void OnRenderImage(RenderTexture src, RenderTexture dest)
	{
		 
			Graphics.Blit(src, dest);
			Graphics.Blit(src, worldPosTex, matss);
		 
		
	}
}

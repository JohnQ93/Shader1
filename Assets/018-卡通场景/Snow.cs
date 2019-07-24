using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Snow : MonoBehaviour
{
    public const string SNOW_ON = "SNOW_ON";
    public const string SNOW_LEVEL = "_Snow";
    void Start()
    {
        Shader.EnableKeyword(SNOW_ON);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Shader.SetGlobalFloat(SNOW_LEVEL, 0.2f);
        }
        else if (Input.GetMouseButton(1))
        {
            Shader.SetGlobalFloat(SNOW_LEVEL, 0.0f);
        }
    }
}

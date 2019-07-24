using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class Tools : MonoBehaviour
{
    public static string SNOW_ON = "SNOW_ON";
    [MenuItem("Tools/Shader/OpenorClose Snow")]
    public static void Snow()
    {
        if (Shader.IsKeywordEnabled(SNOW_ON))
        {
            Shader.DisableKeyword(SNOW_ON);
        }
        else
        {
            Shader.EnableKeyword(SNOW_ON);
        }
    }
}

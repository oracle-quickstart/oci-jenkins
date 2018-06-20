package terraform

import (
	"fmt"
	"reflect"
	"strings"
)

// FormatArgs converts the inputs to a format palatable to terraform. This includes converting the given vars to the format the
// Terraform CLI expects (-var key=value).
func FormatArgs(customVars map[string]interface{}, args ...string) []string {
	varsAsArgs := FormatTerraformVarsAsArgs(customVars)
	return append(args, varsAsArgs...)
}

// FormatTerraformVarsAsArgs formats the given variables as command-line args for Terraform (e.g. of the format -var key=value).
func FormatTerraformVarsAsArgs(vars map[string]interface{}) []string {
	args := []string{}

	for key, value := range vars {
		hclString := toHclString(value)
		argValue := fmt.Sprintf("%s=%s", key, hclString)
		args = append(args, "-var", argValue)
	}

	return args
}

// Terraform allows you to pass in command-line variables using HCL syntax (e.g. -var foo=[1,2,3]). Unfortunately,
// while their golang hcl library can convert an HCL string to a Go type, they don't seem to offer a library to convert
// arbitrary Go types to an HCL string. Therefore, this method is a VERY simple implementation that correctly handles
// ints, booleans, non-nested lists, and non-nested maps. Everything else is forced into a string using Sprintf.
// Hopefully, this approach is good enough for the type of variables we deal with in terratest.
func toHclString(value interface{}) string {
	// Ideally, we'd use a type switch here to identify slices and maps, but we can't do that, because Go doesn't
	// support generics, and the type switch only matches concrete types. So we could match []interface{}, but if
	// a user passes in []string{}, that would NOT match (the same logic applies to maps). Therefore, we have to
	// use reflection and manually convert into []interface{} and map[string]interface{}.

	if slice, isSlice := tryToConvertToGenericSlice(value); isSlice {
		return sliceToHclString(slice)
	} else if m, isMap := tryToConvertToGenericMap(value); isMap {
		return mapToHclString(m)
	} else {
		return primitiveToHclString(value)
	}
}

// Try to convert the given value to a generic slice. Return the slice and true if the underlying value itself was a
// slice and an empty slice and false if it wasn't. This is necessary because Go is a shitty language that doesn't
// have generics, nor useful utility methods built-in. For more info, see: http://stackoverflow.com/a/12754757/483528
func tryToConvertToGenericSlice(value interface{}) ([]interface{}, bool) {
	reflectValue := reflect.ValueOf(value)
	if reflectValue.Kind() != reflect.Slice {
		return []interface{}{}, false
	}

	genericSlice := make([]interface{}, reflectValue.Len())

	for i := 0; i < reflectValue.Len(); i++ {
		genericSlice[i] = reflectValue.Index(i).Interface()
	}

	return genericSlice, true
}

// Try to convert the given value to a generic map. Return the map and true if the underlying value itself was a
// map and an empty map and false if it wasn't. This is necessary because Go is a shitty language that doesn't
// have generics, nor useful utility methods built-in. For more info, see: http://stackoverflow.com/a/12754757/483528
func tryToConvertToGenericMap(value interface{}) (map[string]interface{}, bool) {
	reflectValue := reflect.ValueOf(value)
	if reflectValue.Kind() != reflect.Map {
		return map[string]interface{}{}, false
	}

	reflectType := reflect.TypeOf(value)
	if reflectType.Key().Kind() != reflect.String {
		return map[string]interface{}{}, false
	}

	genericMap := make(map[string]interface{}, reflectValue.Len())

	mapKeys := reflectValue.MapKeys()
	for _, key := range mapKeys {
		genericMap[key.String()] = reflectValue.MapIndex(key).Interface()
	}

	return genericMap, true
}

// Convert a non-nested slice to an HCL string. See ToHclString for details.
func sliceToHclString(slice []interface{}) string {
	hclValues := []string{}

	for _, value := range slice {
		hclValue := primitiveToHclString(value)
		hclValues = append(hclValues, hclValue)
	}

	return fmt.Sprintf("[%s]", strings.Join(hclValues, ", "))
}

// Convert a non-nested map to an HCL string. See ToHclString for details.
func mapToHclString(m map[string]interface{}) string {
	keyValuePairs := []string{}

	for key, value := range m {
		keyValuePair := fmt.Sprintf("%s = %s", key, primitiveToHclString(value))
		keyValuePairs = append(keyValuePairs, keyValuePair)
	}

	return fmt.Sprintf("{%s}", strings.Join(keyValuePairs, ", "))
}

// Convert a primitive, such as a bool, int, or string, to an HCL string. If this isn't a primitive, force its value
// using Sprintf. See ToHclString for details.
func primitiveToHclString(value interface{}) string {
	switch v := value.(type) {
	// Note: due to a Terraform bug, we can't use proper HCL syntax for ints and booleans and instead have
	// to treat EVERYTHING as a string. For more info, see: https://github.com/hashicorp/terraform/issues/7962
	//case int: return strconv.Itoa(v)
	//case bool: return strconv.FormatBool(v)

	default:
		return fmt.Sprintf("\"%v\"", v)
	}
}

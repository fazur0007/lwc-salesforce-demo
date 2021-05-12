public class DependentPicklists {

    private static final String BASE_64_CHARS = ''
            + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
            + 'abcdefghijklmnopqrstuvwxyz'
            + '0123456789+/';

    private class PicklistEntryBean {
        public Boolean active {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }

   

    public static Map<String, List<String>> controllingToDependentValues(SObjectField controlling, SObjectField dependent) {

        Map<String, List<String>> results = new Map<String, List<String>>();

        if (controlling != null && dependent != null) {

             Map<String, Set<Integer>> cache = new Map<String, Set<Integer>>();

            List<String> controllingValues = new List<String>();

            for (PicklistEntry pe : controlling.getDescribe().getPicklistValues()) {
                if (pe.isActive()) {
                    results.put(pe.getValue(), new String[] {});
                    controllingValues.add(pe.getValue());
                }
            }

            for (PicklistEntryBean pe : picklistEntryBeans(dependent.getDescribe().getPicklistValues())) {
                if (pe.active) {
                    for (Integer index : validForToIndices(pe.validFor,cache)) {
                        results.get(controllingValues.get(index)).add(pe.value);
                    }
                }
            }

        }
		System.debug('results>>' + results);
        return results;
    }

    private static Set<Integer> validForToIndices(String validFor, Map<String, Set<Integer>> cache) {

        Set<Integer> indices = cache.get(validFor);
        if (indices == null) {
            indices = new Set<Integer>();

            String validForBits = base64ToBits(validFor);
            for (Integer i = validForBits.indexOf('1'); i >= 0; i = validForBits.indexOf('1', i + 1)) {
                indices.add(i);
            }

            cache.put(validFor, indices);
        }

        return indices;
    }

    private static String decimalToBinary(Integer val) {

        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    private static String base64ToBits(String validFor) {

        if (String.isEmpty(validFor)) return '';

        String validForBits = '';
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = BASE_64_CHARS.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }

    private static PicklistEntryBean[] picklistEntryBeans(List<PicklistEntry> pes) {

        return (List<PicklistEntryBean>) JSON.deserialize(JSON.serialize(pes), List<PicklistEntryBean>.class);
    }
}
/* Copyright (C) 2023 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
package github.koukobin.ermis.server.test.java;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

import github.koukobin.ermis.server.main.java.util.AESGCMCipher;
import github.koukobin.ermis.server.main.java.util.AESKeyGenerator;

/**
 * @author Ilias Koukovinis
 *
 */
public class t {

	/**
	 * @param args
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {
		byte[] key = AESKeyGenerator.genereateRawSecretKey();
		
		System.out.println(new String(key, StandardCharsets.UTF_8));
//		prependWavHeader(
//		        "/home/ilias/test.wav",  // Input raw PCM file
//		        "/home/ilias/test2.wav"  // Output WAV file
//		    );
		
//        Path outputPath = Paths.get("/home/ilias/test.wav");
//    	if (!Files.exists(outputPath)) {
//    		// Write WAV header for the first time
//    		try (OutputStream os = Files.newOutputStream(outputPath, StandardOpenOption.CREATE)) {
//    			os.write(createWavHeader(44100, 2, 16)); // Adjust parameters as needed
//    		}
//    	}
//    	InputStream reader = Files.newInputStream(Paths.get("/home/ilias/untitled.wav"));
//    	while (reader.available() > 0) {
//    		Files.write(outputPath, reader.readNBytes(24), StandardOpenOption.APPEND);
//    	}
	}
	
	private static byte[] createWavHeader(int sampleRate, int channels, int bitsPerSample) {
	    int byteRate = sampleRate * channels * bitsPerSample / 8;
	    int blockAlign = channels * bitsPerSample / 8;

	    ByteBuffer buffer = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN);
	    buffer.put("RIFF".getBytes());
	    buffer.putInt(0); // Placeholder for file size
	    buffer.put("WAVE".getBytes());
	    buffer.put("fmt ".getBytes());
	    buffer.putInt(16); // Subchunk1 size (PCM)
	    buffer.putShort((short) 1); // Audio format (1 = PCM)
	    buffer.putShort((short) channels);
	    buffer.putInt(sampleRate);
	    buffer.putInt(byteRate);
	    buffer.putShort((short) blockAlign);
	    buffer.putShort((short) bitsPerSample);
	    buffer.put("data".getBytes());
	    buffer.putInt(0); // Placeholder for data chunk size
	    return buffer.array();
	}

    public static void prependWavHeader(String rawAudioFile, String wavFile) throws IOException {
        File rawFile = new File(rawAudioFile);
        File wavOutputFile = new File(wavFile);

        // Calculate sizes
        int sampleRate = 44100; // Hz
        int numChannels = 2;    // Stereo
        int bitsPerSample = 16; // 16 bits
        long rawAudioSize = rawFile.length();
        long subchunk2Size = rawAudioSize;
        long chunkSize = 36 + subchunk2Size;
        int byteRate = sampleRate * numChannels * bitsPerSample / 8;
        int blockAlign = numChannels * bitsPerSample / 8;

        // Write WAV header
        try (FileOutputStream wavOut = new FileOutputStream(wavOutputFile);
             FileInputStream rawIn = new FileInputStream(rawFile)) {

            // RIFF Chunk
            wavOut.write("RIFF".getBytes());
            wavOut.write(intToLittleEndian((int) chunkSize));
            wavOut.write("WAVE".getBytes());

            // fmt subchunk
            wavOut.write("fmt ".getBytes());
            wavOut.write(intToLittleEndian(16)); // Subchunk1Size for PCM
            wavOut.write(shortToLittleEndian((short) 1)); // AudioFormat (1 = PCM)
            wavOut.write(shortToLittleEndian((short) numChannels));
            wavOut.write(intToLittleEndian(sampleRate));
            wavOut.write(intToLittleEndian(byteRate));
            wavOut.write(shortToLittleEndian((short) blockAlign));
            wavOut.write(shortToLittleEndian((short) bitsPerSample));

            // data subchunk
            wavOut.write("data".getBytes());
            wavOut.write(intToLittleEndian((int) subchunk2Size));

            // Write raw audio data
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = rawIn.read(buffer)) != -1) {
                wavOut.write(buffer, 0, bytesRead);
            }
        }
    }

    private static byte[] intToLittleEndian(int value) {
        return ByteBuffer.allocate(4).order(java.nio.ByteOrder.LITTLE_ENDIAN).putInt(value).array();
    }

    private static byte[] shortToLittleEndian(short value) {
        return ByteBuffer.allocate(2).order(java.nio.ByteOrder.LITTLE_ENDIAN).putShort(value).array();
    }
}

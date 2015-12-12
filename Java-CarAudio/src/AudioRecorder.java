import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.SourceDataLine;
import javax.sound.sampled.TargetDataLine;

public class AudioRecorder {

	public static void main(String[] args) {

		// konstruktor objektu AudioFormat AudioFormat(float sampleRate, int
		// sampleSizeInBits, int channels, boolean signed, boolean bigEndian)
		AudioFormat format = new AudioFormat(44100.0f, 16, 1, true, true);
		// TargetDataLine - linia z ktorej dane moga byc sczytane
		TargetDataLine microphone;
		// reprezentuje strumieñ danych wejœciowych w konkretnym formacie i
		// majacy konkretna dlugosc
		AudioInputStream audioInputStream;
		// to jest linia do której dane moga byc zapisane
		SourceDataLine sourceDataLine;
		try {
			// tworzy nam obiekt targetDataLine który reprezentuje mikrofon i
			// jest w formacie zadanym przez obiekt format
			microphone = AudioSystem.getTargetDataLine(format);

			// tutaj bierzemy sobie info odnosnie linii. Java bierze sobie to
			// urz¹dzenie do nagrywania które jest jako domyslne w systemie.
			DataLine.Info info = new DataLine.Info(TargetDataLine.class, format);

			// tutaj sobei zapisujemy to urz¹dzenie jako mikrofon
			microphone = (TargetDataLine) AudioSystem.getLine(info);

			// open(AudioFormat format)
			// Opens the line with the specified format, causing the line to
			// acquire any required system resources and become operational.
			microphone.open(format);

			// to jest normalny output stream z tym ¿e dane s¹ zapisywane w
			// tablicach
			ByteArrayOutputStream out = new ByteArrayOutputStream();

			// liczba przeczytanych danych, po to ¿eby móc policzyæ ile
			// nagralismy i porównaæ z bytesRead w pêtli
			int numBytesRead;

			// ilosc bajtów która ma byæ sczytywana przy jednym readzie
			int CHUNK_SIZE = 1024;
			// nowa tablica bajtóW buffersize = fs nie wiedziec czemu to jest
			// podzielone przez 5, ale bez podzielenia te¿ dzia³a
			byte[] data = new byte[microphone.getBufferSize() / 5];

			// otworzenie linii dzieki czemu mo¿na nagrywaæ
			microphone.start();

			int bytesRead = 0;

			try {
				while (bytesRead < 500000) { // Just so I can test if recording
												// my mic works...

					// read(byte[] zmienna do której zapisujemy,int offset od
					// poczatku tablicy,int ile odczytaæ bajtów)
					numBytesRead = microphone.read(data, 0, CHUNK_SIZE);
					bytesRead = bytesRead + numBytesRead;
					System.out.println(bytesRead);
					// zapisujemy data do objektu out.
					out.write(data, 0, numBytesRead);

				}
			} catch (Exception e) {
				e.printStackTrace();
			}

			byte audioData[] = out.toByteArray();
			// Get an input stream on the byte array
			// containing the data
			InputStream byteArrayInputStream = new ByteArrayInputStream(audioData);
			audioInputStream = new AudioInputStream(byteArrayInputStream, format,
					audioData.length / format.getFrameSize());
			DataLine.Info dataLineInfo = new DataLine.Info(SourceDataLine.class, format);
			sourceDataLine = (SourceDataLine) AudioSystem.getLine(dataLineInfo);
			sourceDataLine.open(format);
			sourceDataLine.start();
			int cnt = 0;
			byte tempBuffer[] = new byte[10000];

			try {
				while ((cnt = audioInputStream.read(tempBuffer, 0, tempBuffer.length)) != -1) {
					if (cnt > 0) {
						// Write data to the internal buffer of
						// the data line where it will be
						// delivered to the speaker.
						sourceDataLine.write(tempBuffer, 0, cnt);
					} // end if
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
			// Block and wait for internal buffer of the
			// data line to empty.
			sourceDataLine.drain();
			sourceDataLine.close();
			microphone.close();
		} catch (LineUnavailableException e) {
			e.printStackTrace();
		}
	}
}
